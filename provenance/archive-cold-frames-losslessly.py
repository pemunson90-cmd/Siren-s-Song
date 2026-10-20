from pathlib import Path
from PIL import Image
import subprocess,json,hashlib,os,shutil,time,sys
session,batch=sys.argv[1:3];assert session in ['whole-game-cautious-1','whole-game-cautious-reconnected-1','stakes-fresh-inner-1','stakes-fleet-inner-2']
base=Path('/workspace/Siren-s-Song-gauntlet-archives');source=base/'live-input-harness-demand/sessions'/session;out=base/'cold-frames';out.mkdir(exist_ok=True)
stem=f'{session}-rgb-{batch}';movie=out/(stem+'.mkv');manifest=out/(stem+'.json');scratch=Path('/workspace/work/storage')/stem
assert not movie.exists() and not manifest.exists() and not scratch.exists();scratch.mkdir();decoded=scratch/'decoded';decoded.mkdir();rows=[];total=0;dimensions=None
for p in sorted(source.glob('*.png')):
 st=p.stat()
 if not p.stem.isdigit() or len(p.stem)<15 or st.st_nlink!=1 or time.time()-st.st_mtime<3600:continue
 with Image.open(p) as im:
  if im.mode not in ['RGB','RGBA']:continue
  if dimensions is None:dimensions=im.size
  if im.size!=dimensions:continue
  fmt=4 if im.mode=='RGB' else 5
 rows.append({'path':str(p),'index':len(rows)+1,'format':fmt,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':st.st_size,'inode':st.st_ino,'mtime_ns':st.st_mtime_ns});total+=st.st_size
 if total>=192*1024*1024:break
assert rows
concat=scratch/'frames.concat';concat.write_text(''.join("file '"+r['path']+"'\nduration 0.04\n" for r in rows))
data={'archive':str(movie),'frames':rows,'scope':'Closed-session immutable numeric PNGs; every original PNG byte hash independently reconstructed from lossless RGB video using pinned Godot4.6.3 before local eviction. Source, saves, logs, named keyframes, builds and signer untouched.','encoding':'libx264rgb CRF0 bgr24; lossless RGB; Godot Image format restored per frame','storage_frame_clock':'Synthetic25fps archive index; original screenshot timing remains in filenames and unchanged input logs.','original_bytes':total,'free_before':shutil.disk_usage('/workspace').free,'godot_version':subprocess.check_output(['godot','--version'],text=True).strip()};manifest.write_text(json.dumps(data,indent=2)+'\n')
subprocess.run(['ffmpeg','-v','error','-f','concat','-safe','0','-i',str(concat),'-fps_mode','passthrough','-c:v','libx264rgb','-crf','0','-preset','veryfast','-pix_fmt','bgr24','-threads','2',str(movie)],check=True)
subprocess.run(['ffmpeg','-v','error','-i',str(movie),'-fps_mode','passthrough',str(decoded/'%06d.png')],check=True)
assert len(list(decoded.glob('*.png')))==len(rows)
verified=subprocess.run(['godot','--headless','--path','/workspace/Siren-s-Song-integration/game','--script','/workspace/work/storage/verify-frame-archive.gd','--',str(manifest),str(decoded)],capture_output=True,text=True);(scratch/'verification.log').write_text(verified.stdout+verified.stderr);assert verified.returncode==0,verified.stdout+verified.stderr
for row in rows:
 p=Path(row['path']);st=p.stat();assert st.st_ino==row['inode'] and st.st_nlink==1 and st.st_mtime_ns==row['mtime_ns'] and hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256']
data.update(archive_sha256=hashlib.sha256(movie.read_bytes()).hexdigest(),archive_bytes=movie.stat().st_size,verification=verified.stdout,restoration='Decode all frames with ffmpeg -i ARCHIVE -fps_mode passthrough SCRATCH/%06d.png; then godot --headless --path GAME --script verify-frame-archive.gd -- MANIFEST SCRATCH --restore. Original PNG SHA256 is checked before write; changed originals are never replaced.')
manifest.write_text(json.dumps(data,indent=2)+'\n')
for row in rows:Path(row['path']).unlink()
shutil.rmtree(decoded);data['free_after']=shutil.disk_usage('/workspace').free;manifest.write_text(json.dumps(data,indent=2)+'\n')
with (source/'COLD_FRAMES_RESTORE.txt').open('a') as f:f.write(f'Exact original PNG reconstruction: {manifest}\n{data["restoration"]}\n')
print(json.dumps({k:data[k] for k in ['archive','archive_sha256','original_bytes','archive_bytes','free_before','free_after']}))
