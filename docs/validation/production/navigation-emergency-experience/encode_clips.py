from pathlib import Path
import subprocess,json,hashlib,shutil,sys
name=sys.argv[1];inp=Path(sys.argv[2]).resolve();dst=Path('docs/validation/production/navigation-emergency-experience/motion');out=dst/name;out.mkdir(exist_ok=True)
frames=sorted(inp.glob('[0-9][0-9][0-9][0-9].png'));assert len(frames)==240
hashes={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in frames}
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-framerate','15','-i',str(inp/'%04d.png'),'-frames:v','240','-c:v','libx264','-preset','fast','-crf','18','-threads','2','-pix_fmt','yuv420p','-movflags','+faststart',str(dst/(name+'.mp4'))],check=True)
probe=json.loads(subprocess.check_output(['ffprobe','-v','quiet','-show_streams','-show_format','-of','json',str(dst/(name+'.mp4'))]))
v=next(s for s in probe['streams'] if s['codec_type']=='video');assert (v['width'],v['height'],v['r_frame_rate'])==(1280,720,'15/1');assert int(v['nb_frames'])==240 and float(probe['format']['duration'])==16.0
for i in [0,30,60,120,180,239]:shutil.copyfile(inp/f'{i:04d}.png',out/f'frame-{i:03d}.png')
shutil.copyfile(inp/'chronology.json',out/'chronology.json')
(out/'media-probe.json').write_text(json.dumps(probe,indent=2)+'\n');(out/'raw-frame-sha256.json').write_text(json.dumps(hashes,indent=2)+'\n')
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(dst/(name+'.mp4')),'-vf','fps=1,scale=320:180,tile=4x4','-frames:v','1',str(out/'decoded-1fps.jpg')],check=True)
print(name,v['width'],v['height'],v['nb_frames'],probe['format']['duration'])
