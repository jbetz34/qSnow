/ constants
FRAME:2#RCD:30 80 10 / rows; columns; depth
BOUNDS:`r`c`d!0,'RCD-1 / stay within
FALL:9 / flakes per cycle
PORT:5000+sum`long$"snow"
/ apparent movement diminishes with distance
TRIG:2*atan .5%1+til RCD 2 / https://elvers.us/perception/visualAngle/
WIND:0.3
/ globals
Flakes:([]r:0#0.;c:0#0.;d:0#0.) / row, col; depth
/ functions
rnd:floor .5+
disp:{FRAME#@[prd[FRAME]#" ";FRAME sv x`r`c;:;"#**......."@x`d]} rnd@
advance:{[f]
  dwd:TRIG rnd f`d; / diminish with distance
  gust:-.5+first 1?1f;
  f:update r:r+dwd, c:c+(WIND+gust)*dwd from f;
  f:update r:r+dwd*(count[f]?2.)-1, c:c+dwd*(count[f]?2.)-1 from f; / jiggle
  f:delete from f where any each not f within'\:BOUNDS;
  f upsert flip 0 1 1f*FALL?'RCD } 
/ callback
.z.ph:{.h.hp disp Flakes::advance Flakes}

system "p ",string PORT
-1 "Listening on ",string PORT;
