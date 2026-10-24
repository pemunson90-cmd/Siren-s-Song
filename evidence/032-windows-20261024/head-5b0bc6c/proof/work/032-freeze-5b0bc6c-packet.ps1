$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
$code=Join-Path $PSScriptRoot 'landmarks-merge'
$evidence=Join-Path $PSScriptRoot '032-native'
$sourceSha='5b0bc6c30012606a4026572319aed68da41b4141'
$gameTree='487c1eda9be72a47a384d77743827333335d0295'
$fullTree='721a476df2d73bb59c241b69e922adca18348b09'
$receipt=Join-Path $evidence 'FINAL-5b0bc6c-receipt.json'
if(Test-Path -LiteralPath $receipt){throw 'Final receipt already exists; preserve it'}
if((& git -C $code rev-parse HEAD:game) -ne $gameTree){throw 'Frozen game tree changed'}
& git -C $code diff --quiet -- game
if($LASTEXITCODE -ne 0){throw 'Tracked game working tree changed'}
$raw=Get-Content (Join-Path $evidence 'final-5b0bc6c-native/captures/raw.json') -Raw|ConvertFrom-Json
if(@($raw).Count -ne 120 -or @($raw|Where-Object {$_.snapshot -ne $_.snapshot_after}).Count -ne 0){throw 'Native state packet incomplete'}
$results=@()
foreach($tag in @('final-5b0bc6c-import','final-5b0bc6c-headless','final-5b0bc6c-native')){
 foreach($item in (Get-ChildItem (Join-Path $evidence $tag) -Filter 'results-*.json')){$results+=@(Get-Content $item.FullName -Raw|ConvertFrom-Json)}
}
$commandResult=Get-Content (Join-Path $evidence 'final-5b0bc6c-command/result.json') -Raw|ConvertFrom-Json
if(@($results|Where-Object {-not $_.passed}).Count -gt 0 -or -not $commandResult.passed){throw 'A frozen verification failed'}
function RecordFile($file){
 $item=Get-Item -LiteralPath $file
 [ordered]@{path=[IO.Path]::GetRelativePath($taskRoot,$item.FullName).Replace('\','/');sha256=(Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant();bytes=$item.Length;last_write_utc=$item.LastWriteTimeUtc.ToString('o')}
}
$finalFiles=@()
foreach($tag in @('final-5b0bc6c-import','final-5b0bc6c-headless','final-5b0bc6c-native','final-5b0bc6c-command')){
 foreach($file in (Get-ChildItem (Join-Path $evidence $tag) -File -Recurse)){
  if($file.FullName -notmatch '[\\/](appdata|local|xdg)[\\/]'){$finalFiles+=RecordFile $file.FullName}
 }
}
foreach($file in @('032-run-5b0bc6c-frozen.ps1','032-mesh-command-receipt.gd','032-command-5b0bc6c-run.ps1','032-analyze-5b0bc6c.ps1')){$finalFiles+=RecordFile (Join-Path $PSScriptRoot $file)}
foreach($file in @('gpu-api-verification.json','pass-budget-api-verification.json','final-5b0bc6c-summary.json')){$finalFiles+=RecordFile (Join-Path $evidence $file)}
foreach($file in @('032-art-call-profile.gd','032-profile-run.ps1','032-mesh-short.gd','032-mesh-short-run.ps1','032-freeze-5b0bc6c-packet.ps1')){$finalFiles+=RecordFile (Join-Path $PSScriptRoot $file)}
foreach($tag in @('profile-7619ff1-calls','mesh-short-01')){
 foreach($file in (Get-ChildItem (Join-Path $evidence $tag) -File)){$finalFiles+=RecordFile $file.FullName}
}
foreach($file in @('032-pass-budget-short.gd','032-pass-budget-short-run.ps1','032-pass-budget-analyze.ps1')){$finalFiles+=RecordFile (Join-Path $PSScriptRoot $file)}
foreach($file in (Get-ChildItem (Join-Path $evidence 'pass-budget-short-01') -File)){$finalFiles+=RecordFile $file.FullName}
foreach($file in @('pass-budget-alpha-inspection.json','pass-budget-alpha-inspection-02.json','pass-budget-alpha-inspection-INVALID.txt')){$finalFiles+=RecordFile (Join-Path $evidence $file)}
$sources=@()
foreach($file in @('game/src/presentation/art/art_table.gd','game/src/presentation/art/art_renderer.gd','game/src/presentation/art/art_tests.gd','game/src/presentation/camera_feed.gd','game/src/presentation/confluence_world.gd','game/src/presentation/ocean_view.gd','game/tests/art_render_measurements.gd','game/tests/art_tests.gd','game/tests/suites.txt')){
 $row=RecordFile (Join-Path $code $file);$row['git_path']=$file;$row['git_blob']=(& git -C $code rev-parse ($sourceSha+':'+$file));$sources+=$row
}
$development=@()
foreach($folder in (Get-ChildItem -LiteralPath $evidence -Directory|Where-Object {$_.Name -notlike 'final-*'})){
 foreach($file in (Get-ChildItem -LiteralPath $folder.FullName -File -Recurse)){
  if($file.FullName -notmatch '[\\/](appdata|local|xdg)[\\/]' -and $file.Extension -in @('.log','.json','.png')){$development+=RecordFile $file.FullName}
 }
}
$developmentManifest=Join-Path $evidence 'DEVELOPMENT-032-5b0bc6c-manifest.json'
@{scope='Preserved development, clipped initial baseline, intentional RED and failed fixtures; excluded from final performance claims';files=$development}|ConvertTo-Json -Depth 8|Set-Content -LiteralPath $developmentManifest
$summary=Get-Content (Join-Path $evidence 'final-5b0bc6c-summary.json') -Raw|ConvertFrom-Json
$commands=Get-Content (Join-Path $evidence 'final-5b0bc6c-command/command-receipts.json') -Raw|ConvertFrom-Json
$packet=[ordered]@{
 source=$sourceSha;full_tree=$fullTree;game_tree=$gameTree;source_working_tree_clean=$true;created_utc=(Get-Date).ToUniversalTime().ToString('o')
 status='Artwork candidate with cached meshes and reduced ornament pass budget, full paired measurements for independent review. Artwork acceptance and merge are not claimed.'
 ownership='Only nine owned game source/test paths committed; root docs, board, UID/import churn and personal saves excluded.'
 engine='Godot4.6.3.stable.official.7d41c59c4 Windows Compatibility, Dummy audio, hidden/offscreen, unique APPDATA/LOCALAPPDATA; serial WaitForExit guarded by exclusive file lock and mutex.'
 gpu='NVIDIA GeForce RTX2080Ti, OpenGL3.3.0 NVIDIA610.88; viewport GPU timer enabled, nonzero native samples; Vsync disabled.'
 suites=$results;command_receipt_result=$commandResult
 render_design=@{states=3;physical_viewports=@('2520x1080','2184x1968');dpi=420;cover_safe_inset_pixels=136;inner_safe_inset_pixels=0;text_scale='normal1.0; active ordinary camera case1.5';camera='ordinary Ocean overview; fixed source-known paused states, phase0';order='old/new/new/old';blocks_per_state=5;warmup_frames_per_switch=90;timed_frames_per_switch=300;raw_blocks=120;timed_samples=36000;requested_warmup_draws=10800;scenes=@('ordinary fleet/fresh four roles/stale glyph','explicit source-known earned chart plus complete/partial factory, installation, active FOV guide','ordinary active own camera wash,150%text')}
 correctness='204 native checks: identical complete draw snapshots, source-known hidden roster and private chart geometry pixel invariance, exact old-look return, subsequent ordinary command equivalence, on-screen/unoccluded Quietus and cone, lamp-only pixel difference, real flash preview/exposure/depleted and wide/tight/tele optics. Separate headless command receipt140/0 links all120native rows by full initial state hash and emits numeric command hashes and binary snapshots.'
 art_cache=@{source_audit='No per-frame new arrays/resources/nodes in new art draws. Eight cached meshes replace per-frame triangulation. AA outlines remain unchanged. Unused ornamental aperture meshes/trim were removed. Near-opaque normal Patroller/Sentinel/Hunter material no longer receives a redundant backing; Sweeper holes and all pin-fade backing are retained. Lamp local mesh updates only when actual cached fov/range/steady strength changes; pose uses draw transform. Legacy engine/renderer allocation is not claimed zero.';one_time_headless_geometry_mesh_initialization=$commands.cache;native_retained_counters=@($summary.scenes|ForEach-Object {@{scene=$_.scene;objects_max=$_.objects_delta_range.max;static_bytes_max=$_.static_bytes_delta_range.max}});pin_tint='Exact original continuous modulate, timing, layered pin backing, transforms, outline alpha and snare cues; no tint quantization.'}
 pass_budget='ART58 includes RED-observed budgets for texture+outline Quietus, filled+AA+amber drones, material-only normal backing where safe, retained Sweeper/pin underlay, unchanged shape/UV/index/resource stability. Ad61 and761 remain qualified performance-unmet baselines, not approvals.'
 phase_costs=@($summary.scenes|ForEach-Object {@{scene=$_.scene;draw_cpu_delta_usec=$_.metrics.cpu_usec.paired_delta.median;draw_cpu_repeat_usec=$_.metrics.cpu_usec.maximum_repeat_spread_usec;viewport_cpu_delta_usec=$_.metrics.viewport_render_cpu_usec.paired_delta.median;viewport_cpu_repeat_usec=$_.metrics.viewport_render_cpu_usec.maximum_repeat_spread_usec;gpu_delta_usec=$_.metrics.viewport_render_gpu_usec.paired_delta.median;gpu_repeat_usec=$_.metrics.viewport_render_gpu_usec.maximum_repeat_spread_usec;cadence_delta_usec=$_.metrics.frame_usec.paired_delta.median;cadence_repeat_usec=$_.metrics.frame_usec.maximum_repeat_spread_usec}})
 performance_scope='All four timing phases and their paired/noise-aware distributions are provided; individual phase changes are not hidden. The qualified ad61 baseline led to one bounded ornament/underlay pass reduction with RED contracts and a promising normal-cover short comparison. That actual code change justified this full repeat. No universal Android FPS or power guarantee.'
 residual_phase_cost='Strict per-phase no-regression remains unresolved: inner normal viewport CPU paired+14.5us versus3us maximum repeat spread, and cover ordinary-camera viewport CPU+14.75us versus11us repeat. All6draw CPU and all6whole-frame cadence paired medians improve; GPU improves except coverfactory+0.5us within1us repeat. Remaining extra batches are1..6 after ornament removal, supporting retained filled/AA silhouettes and own-camera presentation. No further architecture or source change is claimed.'
 diagnostic_scope='The7619call profile measured the prior source. The short mesh diagnostic ran after the three Art working-tree files changed and before4eb90db committed those exact files; its launch GitHEAD field therefore still says7619. It is qualifying diagnostic evidence only. Exact ad61 launch/source hashes and full paired data are the final evidence.'
 prior_qualified_baseline=(RecordFile (Join-Path $evidence 'FINAL-7619ff1-receipt.json'))
 prior_ad61_qualified_baseline=(RecordFile (Join-Path $evidence 'FINAL-ad61ad9-receipt.json'))
 limits=@('Pat decides concrete artwork acceptance; shape signatures/source-known scenes do not establish blind role recognition.','No physical Android, vision, hand, haptics or blind-play claim.','Lamp180m cap is an artistic fade bounded by actual cached range, not changed physics, promised visibility or a safe corridor. Earned chart uses a short dashed camera-direction instrument, not filled hidden terrain.','No high-level GPU disjoint flag; zero/nonfinite samples must not be treated as measured GPU performance. Driver power-state/host scheduling noise remains.','015 and supplemental cache/command probes are headless simulation/CPU evidence only.','Initial pre-edit baseline had logical-viewport clipping and is development evidence; final valid pictures are same-source table old/new with corrected DPI/viewport/inset provenance.')
 development_failures=@('Wrong initial core script test.gd missing; corrected registry name run_tests.','Intentional missing-art RED overlapped the development-only core; excluded from final proof.','Packed-array const dictionary parse failure, interrupted owned session; subsequent exact elevated process check empty before resumed serial validation.','Initial old native pictures clipped by physical/logical viewport mismatch; preserved and replaced by corrected same-source pairs.','Depleted-flash fixture used wrong Array.erase(0), corrected to captures[0]={}; original assertion retained.','Earned-region fixture initially omitted required region_revision, corrected fixture metadata; no validator change.')
 source_files=$sources;files=$finalFiles;development_manifest=(RecordFile $developmentManifest)
}
$packet|ConvertTo-Json -Depth 20|Set-Content -LiteralPath $receipt
$ready=[ordered]@{receipt=(RecordFile $receipt);final_files=$finalFiles.Count;source_files=$sources.Count;development_files=$development.Count;all_tests_passed=$true;blanket_no_performance_regression_claim=$false}
$ready|ConvertTo-Json -Depth 8|Set-Content -LiteralPath (Join-Path $evidence 'FINAL-5b0bc6c-READY.json')
$ready|ConvertTo-Json -Depth 8
