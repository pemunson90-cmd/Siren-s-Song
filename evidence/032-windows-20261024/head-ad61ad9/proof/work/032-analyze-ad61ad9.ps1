param([string]$Raw=(Join-Path $PSScriptRoot '032-native/final-ad61ad9-native/captures/raw.json'),[string]$Out=(Join-Path $PSScriptRoot '032-native/final-ad61ad9-summary.json'))
$ErrorActionPreference='Stop'
function Stats([double[]]$Values){
 $valid=@($Values|Where-Object {-not [double]::IsNaN($_) -and -not [double]::IsInfinity($_)})
 if($valid.Count -eq 0){return @{n=0;unavailable=$true}}
 [Array]::Sort($valid)
 $mid=($valid.Count-1)/2
 $median=($valid[[math]::Floor($mid)]+$valid[[math]::Ceiling($mid)])/2
 return [ordered]@{n=$valid.Count;median=$median;p95=$valid[[math]::Min($valid.Count-1,[math]::Ceiling($valid.Count*.95)-1)];min=$valid[0];max=$valid[-1];mean=($valid|Measure-Object -Average).Average}
}
$rows=@(Get-Content -LiteralPath $Raw -Raw|ConvertFrom-Json)
$summaries=@()
foreach($group in ($rows|Group-Object {$_.name -replace '-(old|new)$',''})){
 $scene=$group.Group
 $metrics=[ordered]@{}
 foreach($metric in @('cpu_usec','viewport_render_cpu_usec','viewport_render_gpu_usec','frame_usec')){
  $old=@($scene|Where-Object {-not $_.enabled}|ForEach-Object {$_.$metric})
  $new=@($scene|Where-Object {$_.enabled}|ForEach-Object {$_.$metric})
  $pairs=@()
  foreach($block in ($scene|Group-Object block)){
   $blockOld=@($block.Group|Where-Object {-not $_.enabled})
   $blockNew=@($block.Group|Where-Object {$_.enabled})
   $o0=(Stats $blockOld[0].$metric).median;$o1=(Stats $blockOld[1].$metric).median
   $n0=(Stats $blockNew[0].$metric).median;$n1=(Stats $blockNew[1].$metric).median
   $pairs += [ordered]@{block=[int]$block.Name;old_median=($o0+$o1)/2;new_median=($n0+$n1)/2;delta_usec=(($n0+$n1)-($o0+$o1))/2;old_repeat_spread_usec=[math]::Abs($o0-$o1);new_repeat_spread_usec=[math]::Abs($n0-$n1)}
  }
  $metrics[$metric]=[ordered]@{old=(Stats $old);new=(Stats $new);paired_delta=(Stats @($pairs|ForEach-Object {$_.delta_usec}));paired_blocks=$pairs;maximum_repeat_spread_usec=(@($pairs|ForEach-Object {$_.old_repeat_spread_usec;$_.new_repeat_spread_usec})|Measure-Object -Maximum).Maximum}
 }
 $summaries += [ordered]@{scene=$group.Name;rows=$scene.Count;metrics=$metrics;old_draw_calls=@($scene|Where-Object {-not $_.enabled}|ForEach-Object {$_.draw_calls}|Select-Object -Unique);new_draw_calls=@($scene|Where-Object {$_.enabled}|ForEach-Object {$_.draw_calls}|Select-Object -Unique);objects_delta_range=(Stats @($scene|ForEach-Object {$_.objects_delta}));static_bytes_delta_range=(Stats @($scene|ForEach-Object {$_.static_bytes_delta}));full_state_hashes=@($scene|ForEach-Object {$_.snapshot}|Select-Object -Unique);all_draw_hashes_equal=(@($scene|Where-Object {$_.snapshot -ne $_.snapshot_after}).Count -eq 0);gpu_status=@($scene|ForEach-Object {$_.gpu_timing}|Select-Object -Unique);zero_gpu_samples=@($scene|ForEach-Object {$_.viewport_render_gpu_usec}|Where-Object {$_ -le 0}).Count}
}
$result=[ordered]@{source='ad61ad91821580a971c6a3d5fe6e998d8b8e0522';game_tree='58a045fc1b8b9d19c514f67d520f01073f11619f';raw_rows=$rows.Count;raw_path=$Raw;native_gpu='NVIDIA GeForce RTX2080Ti, Windows OpenGL Compatibility';timing_units='microseconds; official viewport milliseconds multiplied by1000';scope='same-source staged desktop renderer; no Android FPS/ergonomics or blind role-recognition claim';timer_limits='viewport-only measured render time, no high-level disjoint-status flag; nonfinite samples omitted from summary and retained in raw; GPU power-state/host scheduling drift possible';scenes=$summaries}
$result|ConvertTo-Json -Depth 15|Set-Content -LiteralPath $Out
$summaries|ForEach-Object {[pscustomobject]@{scene=$_.scene;old_cpu=$_.metrics.cpu_usec.old.median;new_cpu=$_.metrics.cpu_usec.new.median;paired_cpu_delta=$_.metrics.cpu_usec.paired_delta.median;cpu_repeat_spread=$_.metrics.cpu_usec.maximum_repeat_spread_usec;old_gpu=$_.metrics.viewport_render_gpu_usec.old.median;new_gpu=$_.metrics.viewport_render_gpu_usec.new.median;paired_gpu_delta=$_.metrics.viewport_render_gpu_usec.paired_delta.median;gpu_repeat_spread=$_.metrics.viewport_render_gpu_usec.maximum_repeat_spread_usec;calls=([string]::Join(',', $_.old_draw_calls)+' / '+[string]::Join(',', $_.new_draw_calls));object_max=$_.objects_delta_range.max;bytes_max=$_.static_bytes_delta_range.max}}|Format-Table -AutoSize
