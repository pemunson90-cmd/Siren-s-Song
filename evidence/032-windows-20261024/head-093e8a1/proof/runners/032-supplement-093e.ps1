$ErrorActionPreference='Stop'
$task=Split-Path -Parent $PSScriptRoot
$code=Join-Path $PSScriptRoot 'landmarks-merge'
$evidence=Join-Path $PSScriptRoot '032-native'
$head='093e8a15fb60e105d4c880a4f99cb830d0190023'
$baseline='5b0bc6c30012606a4026572319aed68da41b4141'
$receipt=Join-Path $evidence 'SUPPLEMENTAL-093e-receipt.json'
if(Test-Path -LiteralPath $receipt){throw 'Preserve existing supplement'}
if((& git -C $code rev-parse HEAD) -ne $head){throw 'Exact head moved'}
& git -C $code diff --quiet -- game
if($LASTEXITCODE -ne 0){throw 'Tracked game source changed'}
& git -C $code diff --cached --quiet -- game
if($LASTEXITCODE -ne 0){throw 'Game index changed'}
function FileRow($path){
 $item=Get-Item -LiteralPath $path
 [ordered]@{path=[IO.Path]::GetRelativePath($task,$item.FullName).Replace('\','/');bytes=$item.Length;sha256=(Get-FileHash -LiteralPath $path).Hash.ToLowerInvariant()}
}
$blobs=@()
foreach($path in @('game/src/presentation/art/art_renderer.gd','game/src/presentation/art/art_table.gd','game/src/presentation/art/art_tests.gd','game/src/presentation/ocean_view.gd','game/src/presentation/confluence_world.gd','game/src/presentation/camera_feed.gd','game/tests/art_tests.gd','game/tests/art_render_measurements.gd','game/tests/suites.txt')){
 $old=& git -C $code rev-parse ($baseline+':'+$path)
 $new=& git -C $code rev-parse ($head+':'+$path)
 if($path -ne 'game/tests/suites.txt' -and $old -ne $new){throw ('Consumed Art blob changed '+$path)}
 $blobs+=[ordered]@{path=$path;baseline_blob=$old;current_blob=$new;unchanged=($old -eq $new);sha256=(Get-FileHash (Join-Path $code $path)).Hash.ToLowerInvariant()}
}
$oldRows=@{};$newRows=@{}
foreach($line in (& git -C $code show ($baseline+':game/tests/suites.txt'))){if($line.Trim() -and -not $line.StartsWith('#')){$parts=$line.Split('|');$oldRows[$parts[0]]=$parts}}
foreach($line in (Get-Content (Join-Path $code 'game/tests/suites.txt'))){if($line.Trim() -and -not $line.StartsWith('#')){$parts=$line.Split('|');$newRows[$parts[0]]=$parts}}
foreach($name in $oldRows.Keys){
 if(-not $newRows.ContainsKey($name) -or $oldRows[$name].Count -ne $newRows[$name].Count){throw ('Registry contract changed '+$name)}
 for($i=0;$i -lt $oldRows[$name].Count;$i++){
  if($i -eq 3 -and $name -in @('art_tests','art_render_measurements')){if([int]$newRows[$name][$i] -ne [int]$oldRows[$name][$i]+1){throw 'Unexpected Art rank move'}}
  elseif($oldRows[$name][$i] -cne $newRows[$name][$i]){throw ('Existing registry field changed '+$name)}
 }
}
if($newRows.Count -ne $oldRows.Count+1 -or ($newRows['ai_trace_tests'] -join '|') -ne 'ai_trace_tests|AI TRACE|208|231'){throw 'Unexpected incoming registry entry'}
$changed=@(& git -C $code diff --name-only $baseline $head -- game)
$permitted=@('game/src/diagnostics/AI_TRACE.md','game/src/diagnostics/ai_trace.gd','game/src/diagnostics/ai_trace_table.gd','game/tests/ai_trace_tests.gd','game/tests/suites.txt')
if(@($changed|Where-Object {$_ -notin $permitted}).Count){throw 'Unexpected runtime dependency change'}
$results=@();$files=@()
foreach($tag in @('supplemental-093e-import','supplemental-093e-headless','supplemental-093e-native')){
 foreach($file in (Get-ChildItem (Join-Path $evidence $tag) -File -Recurse)){
  if($file.FullName -notmatch '[\\/](appdata|local|xdg)[\\/]'){$files+=FileRow $file.FullName}
 }
 foreach($file in (Get-ChildItem (Join-Path $evidence $tag) -Filter 'results-*.json')){$results+=@(Get-Content $file.FullName -Raw|ConvertFrom-Json)}
}
if(@($results|Where-Object {-not $_.passed}).Count){throw 'Fresh exact-head checks failed'}
$raw=Get-Content (Join-Path $evidence 'supplemental-093e-native/captures/raw.json') -Raw|ConvertFrom-Json
$prior=Get-Content (Join-Path $evidence 'final-5b0bc6c-native/captures/raw.json') -Raw|ConvertFrom-Json
if(@($raw).Count -ne 8){throw 'Wrong bounded representative size'}
$stateLinks=@()
foreach($row in $raw){
 $matches=@($prior|Where-Object {$_.name -eq $row.name})
 $linked=$matches.Count -gt 0 -and @($matches|Where-Object {$_.snapshot -ne $row.snapshot}).Count -eq 0 -and $row.snapshot_after -eq $row.snapshot
 if(-not $linked){throw 'Representative full state differs from inherited proof'}
 $stateLinks+=[ordered]@{name=$row.name;full_state_hash=$row.snapshot;after_draw_hash=$row.snapshot_after;linked_prior_rows=$matches.Count;matched=$true}
}
$pictures=@()
foreach($file in (Get-ChildItem (Join-Path $evidence 'supplemental-093e-native/captures') -Filter '*.png')){
 $oldFile=Join-Path $evidence ('final-5b0bc6c-native/captures/'+$file.Name)
 $newHash=(Get-FileHash $file.FullName).Hash.ToLowerInvariant();$oldHash=(Get-FileHash $oldFile).Hash.ToLowerInvariant()
 $pictures+=[ordered]@{name=$file.Name;new_sha256=$newHash;prior_sha256=$oldHash;pixel_file_exact=($newHash -eq $oldHash)}
}
$validator=Join-Path $evidence 'supplemental-093e-validator'
New-Item -ItemType Directory -Path $validator|Out-Null
Push-Location $code
try{$lines=& C:/Python314/python.exe -B scripts/toolchain/check-suites.py 2>&1;$exit=$LASTEXITCODE}finally{Pop-Location}
$log=Join-Path $validator 'registry.out.log';$lines|Set-Content $log
if($exit -ne 0 -or @($lines|Where-Object {$_ -match '0 errors, 0 warnings'}).Count -ne 1){throw 'Registry validator failed'}
$files+=FileRow $log
foreach($path in @('032-run-093e-frozen.ps1','032-native-093e-representative.gd','032-native-093e-run.ps1','032-supplement-093e.ps1')){$files+=FileRow (Join-Path $PSScriptRoot $path)}
$out=[ordered]@{
 source=$head;full_tree=(& git -C $code rev-parse 'HEAD^{tree}');game_tree=(& git -C $code rev-parse HEAD:game);created_utc=(Get-Date).ToUniversalTime().ToString('o');tracked_game_clean=$true
 scope='Additive exact-head integration verification only. No source edits, commits, archive changes, full local matrix/APK or repeated full performance matrix.'
 inherited_proof=(FileRow (Join-Path $evidence 'FINAL-5b0bc6c-receipt.json'))
 inherited_proof_scope='Prior full120-row/5x300 art/performance, privacy, factory and command evidence remains linked by identical eight Art source/test blobs and unchanged existing runtime dependencies. Registry alone adds AI TRACE208/231 and moves ART to232/233. Prior measured timing qualifications remain; this bounded run is not a new performance claim.'
 blob_comparison=$blobs;existing_art_blobs_unchanged=8;registry_contract_preserved=$true;game_diff_paths=$changed;runtime_hook_support='Only standalone diagnostics and its test were added. No existing game runtime source or project hook changed; references to ai_trace are confined to diagnostics.'
 fresh_results=$results;validator=@{exit=$exit;summary=($lines -join "`n")}
 representative=@{scene=2;description='Ordinary active own camera at both420dpi Fold7 source-known shapes,150%text, four fresh roles/stale glyph/fleet, old/new/new/old';blocks=1;samples_per_switch=12;raw_rows=8;purpose='Integration-only native render, privacy, exact old-look, lamp and full-state/command assertions; not performance remeasurement';state_links=$stateLinks;picture_comparison=$pictures}
 decision_context='Root reports Pat chose use new and defer remaining work;033 and remote handoff are deferred/cancelled. Root owns docs, PR, board and merge. This receipt records technical verification only, not an independent art/merge approval.'
 files=$files
}
$out|ConvertTo-Json -Depth 15|Set-Content -LiteralPath $receipt
[ordered]@{receipt=(FileRow $receipt);fresh_results=$results.Count;files=$files.Count;unchanged_art_blobs=8;registry_only_change=$true;representative_state_rows=8;exact_picture_files=@($pictures|Where-Object {$_.pixel_file_exact}).Count;all_checks_passed=$true}|ConvertTo-Json -Depth 6|Set-Content (Join-Path $evidence 'SUPPLEMENTAL-093e-READY.json')
Get-Content (Join-Path $evidence 'SUPPLEMENTAL-093e-READY.json') -Raw
