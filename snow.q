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
STAT:0b / show refresh rate& wind
BORING:1b / are you boring?

/ globals
Flakes:([]r:0#0.;c:0#0.;d:0#0.) / row, col; depth
W:0f;R:"0";F:0; / realtime wind, refresh rate, fall

/ functions
disp:{FRAME#@[prd[FRAME]#" ";prd[FRAME]&FRAME sv x`r`c;:;"#**......."@x`d]} 7h$
advance:{[f]
  dwd:TRIG 7h$ f`d; / diminish with distance
  f:update r:r+dwd, c:c+getWind[]*dwd from f; / dynamic wind
  f:update r:r+dwd*(count[f]?2.)-1, c:c+dwd*(count[f]?2.)-1 from f; / jiggle
  f:delete from f where any each not f within'\:BOUNDS; 
  f upsert flip 0 1 1f*getFall[]?'RCD } 
autoRefresh:{ssr[x;"<head><style>";"<head><meta http-equiv='refresh' content='",getRRate[.001],"'><style>"] }
mrate:{6h$1000*.27+.25*sin 6.283185*x%300000} / moving rate 20i thru 520i every 5 min
srate:{sin 6.283185*x%100000} / moving rate -1. thru 1. every 100 sec
getRRate:{:R::string x*RFSH*$[BORING;RATE;mrate .z.t]} / dynamic refresh rate as product of x
getWind:{:W::first (-.5+1?1f)+$[BORING;WIND;srate[.z.t]+.005*mrate[.z.t]-270]} / dynamic wind + gust
getFall:{:F::$[BORING;FALL;first 0|7h$(-1+1?2.)+10*1+srate .z.t]} / dynamic fall rate
sLine:{x,$[STAT;enlist .Q.s genStats[];""]} / display stats on screen
genStats:{([TIME:1#.z.T]REFRESH:1#RFSH;BORING:1#BORING;FALL:F;WIND:1#7h$100*W;RRATE:1#"I"$R)}
updFrame:{[h;w] / update FRAME to window size
	@[;0 1;:;floor (-3+h%15.5;w%8.2)] each `FRAME`RCD;
	BOUNDS::`r`c`d!0,'RCD-1 }

/ callback
.z.ph:{$[RFSH;autoRefresh;(::)] .h.hp sLine disp Flakes::advance Flakes}
.z.ts:{
  @[h;;{:system"t 0"}] raze sLine ,\:[;.h.br]disp Flakes::advance Flakes;
  system"t ",getRRate[1]; }
.z.ws:{
  h::neg .z.w;
  updFrame . "J"$","vs x;
  .z.ts[]; } 

system "S ",string 6h$.01*.z.t
system "p ",string PORT
-1 "Listening on ",string PORT;
