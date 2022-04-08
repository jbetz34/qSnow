/ constants
FRAME:2#RCD:30 80 5 / rows; columns; depth
BOUNDS:`r`c`d!0,'RCD-1 / stay within
FALL:9 / flakes per cycle
PORT:5000+sum`long$"snow"
/ apparent movement diminishes with distance
TRIG:2*atan .5%1+til RCD 2 / https://elvers.us/perception/visualAngle/
WIND:0.3
RFSH:1b / auto refresh
RATE:300 / static refresh rate (ms)
OFFSET:1?100.
STAT:0b / show refresh rate& wind
BORING:1b / are you boring?

/ globals
Flakes:([]r:0#0.;c:0#0.;d:0#0.) / row, col; depth
W:0f;L:0f;R:"0"; / realtime wind, lift, refresh rate

/ functions
disp:{FRAME#@[prd[FRAME]#" ";prd[FRAME]&FRAME sv x`r`c;:;"#**......."@x`d]} 7h$
advance:{[f]
  dwd:TRIG 7h$ f`d; / diminish with distance
  L::first 1?.3f;
  f:update r:r+dwd-L, c:c+getWind[]*dwd from f; // jhb - dynamic wind
  f:update r:r+dwd*(count[f]?2.)-1, c:c+dwd*(count[f]?2.)-1 from f; / jiggle
  f:delete from f where any each not f within'\:BOUNDS; 
  f upsert flip 0 1 1f*FALL?'RCD } 
autoRefresh:{ssr[x;"<head><style>";"<head><meta http-equiv='refresh' content='",.001*getRRate[],"'><style>"] }
mrate:{6h$1000*.52+.5*sin (6.28318%300)*mod[;300]x%1000} / moving rate 20 thru 1020 every 5 min
srate:{sin (6.28318%100)*mod[;100]OFFSET+x%1000} / moving rate -1 thru 1 every 100 sec
getRRate:{:R::string RFSH*$[BORING;RATE;mrate .z.t]} 
getWind:{:W::first (-.5+1?1f)+$[BORING;WIND;.005*mrate[.z.t]*srate .z.t]}
sLine:{x,$[STAT;enlist .Q.s genStats[];""]}
genStats:{([TIME:1#.z.T]REFRESH:1#RFSH;BORING:1#BORING;WIND:1#7h$100*W;RRATE:1#"I"$R)}

/ callback
.z.ph:{$[RFSH;autoRefresh;(::)] .h.hp sLine disp Flakes::advance Flakes}
.z.ts:{
  @[h;;{:system"t 0"}] raze sLine ,\:[;.h.br]disp Flakes::advance Flakes;
  system"t ",getRRate[]
 }
.z.ws:{[]
  h::neg .z.w;
  .z.ts[];
 } 

system "p ",string PORT
-1 "Listening on ",string PORT;
