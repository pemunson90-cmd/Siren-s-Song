$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
$code=Join-Path $PSScriptRoot 'landmarks-merge'
$evidence=Join-Path $PSScriptRoot '032-native'
$sourceSha='ad61ad91821580a971c6a3d5fe6e998d8b8e0522'
$gameTree='58a045fc1b8b9d19c514f67d520f01073f11619f'
$fullTree='4f60c13cd65855283fb1807be77ad2ad01e8dbc1'
$receipt=Join-Path $evidence 'FINAL-ad61ad9-receipt.json'
if(Test-Path -LiteralPath $receipt){throw 'Final receipt already exists; preserve it'}
if((& git -C $code rev-parse HEAD:game) -ne $gameTree){throw 'Frozen game tree changed'}
& git -C $code diff --quiet -- game
if($LASTEXITCODE -ne 0){throw 'Tracked game working tree changed'}
$raw=Get-Content (Join-Path $evidence 'final-ad61ad9-native/captures/raw.json') -Raw|ConvertFrom-Json
if(@($raw).Count -ne 120 -or @($raw|Where-Object {$_.snapshot -ne $_.snapshot_after}).Count -ne 0){throw 'Native state packet incomplete'}
$results=@()
foreach($tag in @('final-ad61ad9-import','final-ad61ad9-headless','final-ad61ad9-native')){
 foreach($item in (Get-ChildItem (Join-Path $evidence $tag) -Filter 'results-*.json')){$results+=@(Get-Content $item.FullName -Raw|ConvertFrom-Json)}
}
$commandResult=Get-Content (Join-Path $evidence 'final-ad61ad9-command/result.json') -Raw|ConvertFrom-Json
if(@($results|Where-Object {-not $_.passed}).Count -gt 0 -or -not $commandResult.passed){throw 'A frozen verification failed'}
function RecordFile($file){
 $item=Get-Item -LiteralPath $file
 [ordered]@{path=[IO.Path]::GetRelativePath($taskRoot,$item.FullName).Replace('\','/');sha256=(Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant();bytes=$item.Length;last_write_utc=$item.LastWriteTimeUtc.ToString('o')}
}
$finalFiles=@()
foreach($tag in @('final-ad61ad9-import','final-ad61ad9-headless','final-ad61ad9-native','final-ad61ad9-command')){
 foreach($file in (Get-ChildItem (Join-Path $evidence $tag) -File -Recurse)){
  if($file.FullName -notmatch '[\\/](appdata|local|xdg)[\\/]'){$finalFiles+=RecordFile $file.FullName}
 }
}
foreach($file in @('032-run-ad61ad9-frozen.ps1','032-mesh-command-receipt.gd','032-command-ad61ad9-run.ps1','032-analyze-ad61ad9.ps1')){$finalFiles+=RecordFile (Join-Path $PSScriptRoot $file)}
foreach($file in @('gpu-api-verification.json','mesh-api-verification.json','final-ad61ad9-summary.json')){$finalFiles+=RecordFile (Join-Path $evidence $file)}
foreach($file in @('032-art-call-profile.gd','032-profile-run.ps1','032-mesh-short.gd','032-mesh-short-run.ps1','032-freeze-ad61ad9-packet.ps1')){$finalFiles+=RecordFile (Join-Path $PSScriptRoot $file)}
foreach($tag in @('profile-7619ff1-calls','mesh-short-01')){
 foreach($file in (Get-ChildItem (Join-Path $evidence $tag) -File)){$finalFiles+=RecordFile $file.FullName}
}
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
$developmentManifest=Join-Path $evidence 'DEVELOPMENT-032-ad61ad9-manifest.json'
@{scope='Preserved development, clipped initial baseline, intentional RED and failed fixtures; excluded from final performance claims';files=$development}|ConvertTo-Json -Depth 8|Set-Content -LiteralPath $developmentManifest
$summary=Get-Content (Join-Path $evidence 'final-ad61ad9-summary.json') -Raw|ConvertFrom-Json
$commands=Get-Content (Join-Path $evidence 'final-ad61ad9-command/command-receipts.json') -Raw|ConvertFrom-Json
$packet=[ordered]@{
 source=$sourceSha;full_tree=$fullTree;game_tree=$gameTree;source_working_tree_clean=$true;created_utc=(Get-Date).ToUniversalTime().ToString('o')
 status='Artwork candidate with cached-mesh performance fix and full paired measurements for independent review. Artwork acceptance and merge are not claimed.'
 ownership='Only nine owned game source/test paths committed; root docs, board, UID/import churn and personal saves excluded.'
 engine='Godot4.6.3.stable.official.7d41c59c4 Windows Compatibility, Dummy audio, hidden/offscreen, unique APPDATA/LOCALAPPDATA; serial WaitForExit guarded by exclusive file lock and mutex.'
 gpu='NVIDIA GeForce RTX2080Ti, OpenGL3.3.0 NVIDIA610.88; viewport GPU timer enabled, nonzero native samples; Vsync disabled.'
 suites=$results;command_receipt_result=$commandResult
 render_design=@{states=3;physical_viewports=@('2520x1080','2184x1968');dpi=420;cover_safe_inset_pixels=136;inner_safe_inset_pixels=0;text_scale='normal1.0; active ordinary camera case1.5';camera='ordinary Ocean overview; fixed source-known paused states, phase0';order='old/new/new/old';blocks_per_state=5;warmup_frames_per_switch=90;timed_frames_per_switch=300;raw_blocks=120;timed_samples=36000;requested_warmup_draws=10800;scenes=@('ordinary fleet/fresh four roles/stale glyph','explicit source-known earned chart plus complete/partial factory, installation, active FOV guide','ordinary active own camera wash,150%text')}
 correctness='204 native checks: identical complete draw snapshots, source-known hidden roster and private chart geometry pixel invariance, exact old-look return, subsequent ordinary command equivalence, on-screen/unoccluded Quietus and cone, lamp-only pixel difference, real flash preview/exposure/depleted and wide/tight/tele optics. Separate headless command receipt140/0 links all120native rows by full initial state hash and emits numeric command hashes and binary snapshots.'
 art_cache=@{source_audit='No per-frame new arrays/resources/nodes in new art draws. Body triangle meshes, UV/index data and aperture discs are prepared once. AA outlines remain unchanged. Lamp local mesh updates only when actual cached fov/range/steady strength changes; pose uses draw transform. Legacy engine/renderer allocation is not claimed zero.';one_time_headless_geometry_mesh_initialization=$commands.cache;native_retained_counters=@($summary.scenes|ForEach-Object {@{scene=$_.scene;objects_max=$_.objects_delta_range.max;static_bytes_max=$_.static_bytes_delta_range.max}});pin_tint='Exact original continuous modulate, timing, transforms, outline alpha and snare cues; no tint quantization.'}
 phase_costs=@($summary.scenes|ForEach-Object {@{scene=$_.scene;draw_cpu_delta_usec=$_.metrics.cpu_usec.paired_delta.median;draw_cpu_repeat_usec=$_.metrics.cpu_usec.maximum_repeat_spread_usec;viewport_cpu_delta_usec=$_.metrics.viewport_render_cpu_usec.paired_delta.median;viewport_cpu_repeat_usec=$_.metrics.viewport_render_cpu_usec.maximum_repeat_spread_usec;gpu_delta_usec=$_.metrics.viewport_render_gpu_usec.paired_delta.median;gpu_repeat_usec=$_.metrics.viewport_render_gpu_usec.maximum_repeat_spread_usec;cadence_delta_usec=$_.metrics.frame_usec.paired_delta.median;cadence_repeat_usec=$_.metrics.frame_usec.maximum_repeat_spread_usec}})
 performance_scope='All four timing phases and their paired/noise-aware distributions are provided; individual phase changes are not hidden. Source/profile diagnosed prior measured canvas submission regression, then cache meshes changed actual code and justified this full repeat. No universal Android FPS or power guarantee.'
 diagnostic_scope='The7619call profile measured the prior source. The short mesh diagnostic ran after the three Art working-tree files changed and before4eb90db committed those exact files; its launch GitHEAD field therefore still says7619. It is qualifying diagnostic evidence only. Exact ad61 launch/source hashes and full paired data are the final evidence.'
 prior_qualified_baseline=(RecordFile (Join-Path $evidence 'FINAL-7619ff1-receipt.json'))
 limits=@('Pat decides concrete artwork acceptance; shape signatures/source-known scenes do not establish blind role recognition.','No physical Android, vision, hand, haptics or blind-play claim.','Lamp180m cap is an artistic fade bounded by actual cached range, not changed physics, promised visibility or a safe corridor. Earned chart uses a short dashed camera-direction instrument, not filled hidden terrain.','No high-level GPU disjoint flag; zero/nonfinite samples must not be treated as measured GPU performance. Driver power-state/host scheduling noise remains.','015 and supplemental cache/command probes are headless simulation/CPU evidence only.','Initial pre-edit baseline had logical-viewport clipping and is development evidence; final valid pictures are same-source table old/new with corrected DPI/viewport/inset provenance.')
 development_failures=@('Wrong initial core script test.gd missing; corrected registry name run_tests.','Intentional missing-art RED overlapped the development-only core; excluded from final proof.','Packed-array const dictionary parse failure, interrupted owned session; subsequent exact elevated process check empty before resumed serial validation.','Initial old native pictures clipped by physical/logical viewport mismatch; preserved and replaced by corrected same-source pairs.','Depleted-flash fixture used wrong Array.erase(0), corrected to captures[0]={}; original assertion retained.','Earned-region fixture initially omitted required region_revision, corrected fixture metadata; no validator change.')
 source_files=$sources;files=$finalFiles;development_manifest=(RecordFile $developmentManifest)
}
$packet|ConvertTo-Json -Depth 20|Set-Content -LiteralPath $receipt
$ready=[ordered]@{receipt=(RecordFile $receipt);final_files=$finalFiles.Count;source_files=$sources.Count;development_files=$development.Count;all_tests_passed=$true;blanket_no_performance_regression_claim=$false}
$ready|ConvertTo-Json -Depth 8|Set-Content -LiteralPath (Join-Path $evidence 'FINAL-ad61ad9-READY.json')
$ready|ConvertTo-Json -Depth 8
