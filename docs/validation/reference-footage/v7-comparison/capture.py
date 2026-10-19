import asyncio,json,time,hashlib
from pathlib import Path
from playwright.async_api import async_playwright
root=Path('/tmp/sirens-v7-browser')
source=Path('/workspace/Siren-s-Song-gauntlet/reference/original-prototype/sirens_song_prototype_v7.html')
async def main():
 async with async_playwright() as p:
  browser=await p.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--disable-dev-shm-usage'])
  context=await browser.new_context(viewport={'width':1100,'height':1000},record_video_dir=str(root),record_video_size={'width':1100,'height':1000})
  page=await context.new_page();errors=[];page.on('pageerror',lambda e:errors.append(str(e)))
  await page.route('https://**/*',lambda route:route.abort())
  await page.set_content(source.read_text(),wait_until="domcontentloaded");await page.locator('#startBtn').click()
  samples=[]
  async def sample(label):
   value=await page.evaluate('({T,screen,paused,sub:{x:sub.x,y:sub.y},sirens:sirens.map(s=>({type:s.type,x:s.x,y:s.y,invT:s.invT,sees:s._sees,wi:s.wi}))})')
   samples.append({'label':label,'monotonic':time.monotonic(),**value})
  await sample('idle-start');await page.screenshot(path=str(root/'idle-start.png'))
  for n in range(16):await page.wait_for_timeout(1000);await sample('idle-'+str(n+1))
  await page.screenshot(path=str(root/'idle-end.png'))
  await page.locator('#pingBtn').click();await sample('ordinary-ping')
  for n in range(16):await page.wait_for_timeout(1000);await sample('response-'+str(n+1))
  await page.screenshot(path=str(root/'response-end.png'))
  (root/'runtime.json').write_text(json.dumps({'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'browser':browser.version,'external_font_blocked':True,'errors':errors,'samples':samples},indent=2)+'\n')
  video=page.video;await context.close();await video.save_as(str(root/'v7-full.webm'));await browser.close()
asyncio.run(main())
