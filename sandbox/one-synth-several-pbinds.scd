// One synth, where different Pbinds control different parameters in different time
(
p = Pproto(
   {
       ~id = (
           type: \on,
           dur: 0,
           instrument: \default,
           amp: 1,
       ).yield[\id];
       ~type = \set;
   },
   Ppar([
       Pbind(
           \args, #[freq],
           \freq, Pseq([49,47,50,48]-12,inf).midicps,
           \dur, 4,
       ),
       Pbind(
           \args, #[cf],
           \cf, Pseq([100,Prand([700,400,1100],3)],inf),
           \stutter, Prand([1,2,4,8],inf),
           \dur, PdurStutter(Pkey(\stutter)*2, 2),
       ),
       Pbind(
           \args, #[wobble],
           \wobble, Pxrand([3,1.5,6],inf),
           \dur, Prand([2,1],inf),
       ),
       Pbind(
           \args, #[t_bd],
           \t_bd, Pseq([1,0,0,1],inf),
           \dur, 0.5,
       ),
       Pbind(
           \args, #[t_sd],
           \t_sd, Pseq([0,0,1,0],inf),
           \dur, 0.5,
       ),
       Pbind(
           \args, #[pw],
           \pw, Prand([0.4,0.3,0.5],inf),
           \dur, 2,
       ),
   ])
).play;
)