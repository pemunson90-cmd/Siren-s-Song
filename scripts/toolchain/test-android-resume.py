#!/usr/bin/env python3
"""Resume contract and actual PNG decoding; ADB alone is unavailable/mocked."""
import importlib.util,json,os,pathlib,struct,subprocess,sys,tempfile,unittest,zlib
sys.dont_write_bytecode=True
ROOT=pathlib.Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('capture_fixtures',ROOT/'test-android-capture.py');fixture=importlib.util.module_from_spec(spec);spec.loader.exec_module(fixture)
BLACK=ROOT/'fixtures/native-cover-resume-black.png'
def png(rgb):
 def chunk(kind,data):return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data)&0xffffffff)
 return b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',len(rgb)//3,1,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(b'\0'+bytes(rgb)))+chunk(b'IEND',b'')
class ResumeTests(unittest.TestCase):
 def invoke(self,text,before=''):
  with tempfile.TemporaryDirectory() as folder:
   p=pathlib.Path(folder)
   for name,value in [('log',text),('before',before),('density','Physical density: 420\n')]: (p/name).write_text(value)
   (p/'png').write_bytes(b'\x89PNG\r\n\x1a\n'+b'\0'*8+struct.pack('>II',2520,1080))
   return subprocess.run([sys.executable,str(ROOT/'android-capture.py'),str(p/'log'),str(p/'png'),'--density',str(p/'density'),'--after-log',str(p/'before'),'--kind','resumed-mission','--mission','0'],capture_output=True,text=True)
 def decode(self,path):
  return subprocess.run([os.environ.get('GODOT_BIN','godot'),'--headless','--path',str(ROOT.parent.parent/'game'),'--script',str(ROOT/'check-nonblank-frame.gd'),'--','--image='+str(path)],capture_output=True,text=True)
 def test_resume_requires_fresh_foreground_marker_and_postdraw(self):
  text='SS_LIFECYCLE foreground\n'+fixture.records(fixture.layout('restored-mission'))
  r=self.invoke(text);self.assertEqual(r.returncode,0,r.stderr)
 def test_old_or_missing_foreground_report_never_reused(self):
  d=fixture.records(fixture.layout('restored-mission'))
  for text,before in [(d,''),(d+'SS_LIFECYCLE foreground\n',''),('SS_LIFECYCLE foreground\n'+d,'SS_LIFECYCLE foreground\n'+d)]:self.assertEqual(self.invoke(text,before).returncode,3)
 def test_incomplete_latest_or_layout_only_waits(self):
  d=fixture.layout('restored-mission');text='SS_LIFECYCLE foreground\n'+fixture.records(d)
  self.assertEqual(self.invoke(text+fixture.records(d,'42:2').splitlines()[0]+'\n').returncode,3)
  d['capture_state']['phase']='layout_only';self.assertEqual(self.invoke('SS_LIFECYCLE foreground\n'+fixture.records(d)).returncode,3)
 def test_malformed_report_stays_fatal_even_without_foreground_ack(self):
  d=fixture.layout('restored-mission');d['capture_state']['paused']='yes';self.assertEqual(self.invoke(fixture.records(d)).returncode,1)
 def test_real_godot_rejects_original_allblack_native_frame(self):
  r=self.decode(BLACK);self.assertEqual(r.returncode,3,r.stdout+r.stderr);self.assertIn('SS_FRAME_PIXELS nonblank=false',r.stdout)
 def test_real_godot_accepts_rgb_variation_but_not_uniform_white(self):
  with tempfile.TemporaryDirectory() as folder:
   p=pathlib.Path(folder)/'frame.png';p.write_bytes(png([0,0,0,255,255,255]));r=self.decode(p);self.assertEqual(r.returncode,0,r.stdout+r.stderr);self.assertIn('SS_FRAME_PIXELS nonblank=true',r.stdout)
   p.write_bytes(png([255,255,255,255,255,255]));r=self.decode(p);self.assertEqual(r.returncode,3,r.stdout+r.stderr)
 def test_real_decoder_invalid_png_is_fatal(self):
  with tempfile.TemporaryDirectory() as folder:
   p=pathlib.Path(folder)/'frame.png';p.write_bytes(b'not a PNG');r=self.decode(p);self.assertEqual(r.returncode,1);self.assertIn('SS_FRAME_PIXELS invalid',r.stdout)
 def shell(self,frames):
  with tempfile.TemporaryDirectory() as folder:
   p=pathlib.Path(folder);(p/'before').write_text('');(p/'events').touch();(p/'count').write_text('0')
   (p/'log').write_text('SS_LIFECYCLE foreground\n'+fixture.records(fixture.layout('restored-mission')))
   (p/'good.png').write_bytes(BLACK.read_bytes())
   # Real nonuniform full-size PNG using stdlib encoder; no visual-identity claim.
   width,height=2520,1080
   def chunk(kind,data):return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data)&0xffffffff)
   raw=b'\0'+bytes([255,255,255])+bytes((width-1)*3)
   (p/'good.png').write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',width,height,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(raw+(b'\0'+bytes(width*3))*(height-1)))+chunk(b'IEND',b''))
   (p/'black.png').write_bytes(BLACK.read_bytes())
   script='''set -euo pipefail
source "$1/android-capture-smoke.sh"
output="$2"; GAME_DIR="$1/../../game"; GODOT_BIN=godot
stage() { :; }
read_logcat() { cp "$output/log" "$1"; }
sleep() { echo retry >>"$output/events"; }
adb() {
 if [[ "$*" == 'shell wm density' ]]; then echo 'Physical density: 420';return;fi
 local n; n=$(cat "$output/count");n=$((n+1));echo "$n" >"$output/count"
 if ((n>=GOOD_AT));then cat "$output/good.png";else cat "$output/black.png";fi
}
capture_state_shot cover-resume resumed-mission "$output/before" 0 "$1/android-capture.py" "$1/check-nonblank-frame.gd"
'''.replace('GOOD_AT',str(frames))
   r=subprocess.run(['bash','-c',script,'test',str(ROOT),str(p)],capture_output=True,text=True)
   return r,(p/'cover-resume.png').exists(),len(list(p.glob('cover-resume-rejected-*.png'))),(p/'events').read_text()
 def test_black_candidate_is_retained_then_later_nonblank_can_be_final(self):
  r,final,rejected,events=self.shell(3);self.assertEqual(r.returncode,0,r.stdout+r.stderr);self.assertTrue(final);self.assertEqual(rejected,1);self.assertIn('retry',events)
 def test_bounded_allblack_candidates_never_become_final(self):
  r,final,rejected,events=self.shell(100);self.assertNotEqual(r.returncode,0);self.assertFalse(final);self.assertEqual(rejected,10)
if __name__=='__main__':unittest.main()
