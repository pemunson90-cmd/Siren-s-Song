#!/usr/bin/env python3
"""Atomic Android metric transport guards; no geometry rules are relaxed."""
import base64,hashlib,importlib.util,json,pathlib,sys,unittest
sys.dont_write_bytecode=True
spec=importlib.util.spec_from_file_location('records',pathlib.Path(__file__).with_name('android_metric_records.py'))
records=importlib.util.module_from_spec(spec);spec.loader.exec_module(records)
def parts(value,identity='123:1',size=450):
 raw=json.dumps(value,ensure_ascii=False).encode();chunks=[raw[i:i+size] for i in range(0,len(raw),size)]
 return [f'SS_UI_METRICS_PART id={identity} part={i} parts={len(chunks)} bytes={len(raw)} sha256={hashlib.sha256(raw).hexdigest()} data={base64.b64encode(chunk).decode()}' for i,chunk in enumerate(chunks)]
class Tests(unittest.TestCase):
 def test_complete_large_unicode_snapshot(self):
  value={'controls':[{'action':str(i),'label':'é海'*100} for i in range(20)]};lines=parts(value)
  self.assertLess(max(map(len,lines)),1023)
  decoded=records.read_records('\n'.join('10-19 I godot : '+x for x in lines))
  self.assertEqual(len(decoded),1);self.assertEqual(json.loads(decoded[-1][1]),value)
 def test_latest_incomplete_never_falls_back(self):
  lines=parts({'old':True})+parts({'new':'x'*1000},'123:2')[:-1]
  result=records.read_records('\n'.join(lines));self.assertEqual(len(result),2);self.assertIsNone(result[-1][1])
 def test_interleaved_ids_do_not_mix(self):
  a=parts({'a':'x'*900},'1:1');b=parts({'b':'y'*900},'2:1')
  lines=[item for pair in zip(a,b) for item in pair]
  result=records.read_records('\n'.join(lines));self.assertEqual([json.loads(x[1]) for x in result],[{'a':'x'*900},{'b':'y'*900}])
 def test_duplicate_part_rejected(self):
  line=parts({'a':1})[0]
  with self.assertRaises(ValueError):records.read_records(line+'\n'+line)
 def test_conflicting_metadata_rejected(self):
  lines=parts({'a':'x'*1000});lines[1]=lines[1].replace('bytes=1009','bytes=1010')
  with self.assertRaises(ValueError):records.read_records('\n'.join(lines))
 def test_corrupt_hash_rejected(self):
  line=parts({'a':1})[0];digest=line.split('sha256=')[1].split()[0];line=line.replace(digest,'0'*64)
  with self.assertRaises(ValueError):records.read_records(line)
 def test_invalid_base64_rejected(self):
  line=parts({'a':1})[0].split('data=')[0]+'data=!!!'
  with self.assertRaises(ValueError):records.read_records(line)
 def test_oversized_count_rejected(self):
  line=parts({'a':1})[0].replace('parts=1','parts=100000000')
  with self.assertRaises(ValueError):records.read_records(line)
 def test_legacy_snapshot_position_preserved(self):
  self.assertEqual(records.read_records('noise\nSS_UI_METRICS {"x":1}'),[(1,'{"x":1}')])
if __name__=='__main__':unittest.main()
