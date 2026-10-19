const fs=require('fs'),vm=require('vm');
const html=fs.readFileSync(process.argv[2],'utf8');
const node={style:{},classList:{add(){},remove(){},toggle(){}},addEventListener(){},getBoundingClientRect(){return {width:800,height:600}},getContext(){return {createRadialGradient(){return {addColorStop(){}}}}}};
const sandbox={document:{getElementById(){return node}},window:{addEventListener(){}},performance:{now(){return 0}},requestAnimationFrame(){},setTimeout(){},Math,console};
vm.createContext(sandbox);vm.runInContext(html.match(/<script>([\s\S]*?)<\/script>/)[1],sandbox);
const result=vm.runInContext(`(()=>{
 const out={};
 const setup=()=>{init();screen='playing';sub.x=300;sub.y=1500;sub.h=0;sub.tx=1000;sub.ty=1500;obstacles=[];currents=[];logs=[];sirens=[];};
 const enemy=()=>({type:'hunter',x:500,y:1500,detect:0,stun:0,invX:0,invY:0,invT:0,pat:0,chase:0,home:{x:500,y:1500}});
 out.noise=[];
 for(const speed of [0,48,72,96]){setup();sub.spd=speed;sub.tx=sub.x+CFG.arriveR*speed/CFG.maxSpeed;sirens=[enemy()];update(1/60);out.noise.push({speed,formulaRadius:360*speed/96,investigates:sirens[0].invT>0,sees:sirens[0]._sees,suspicion});}
 setup();sub.spd=96;sub.silent=true;sirens=[enemy()];update(1/60);out.silent={speedAfter:sub.spd,investigates:sirens[0].invT>0};
 
 
 out.heartbeats=[];for(const initial of [40,90]){setup();suspicion=initial;let count=0;AU.beat=()=>count++;for(let i=0;i<120;i++)update(1/60);out.heartbeats.push({initial,countIn2s:count});}
 setup();sub.y=1500;const d={detect:150};const outside=effDetect(d);sub.y=WORLD_H*0.42;out.thermal={outside,inside:effDetect(d)};
 return out;
})()`,sandbox);console.log(JSON.stringify({source:process.argv[2],result},null,2));
