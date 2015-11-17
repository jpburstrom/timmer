s.boot;

SynthDef(\marimba, {arg out=0, amp=0.3, t_trig=1, sustain=0.5, gate=1,
freq=100, rq=0.006;
var env, signal;
var rho, theta, b1, b2;
env = EnvGen.kr(Env.adsr(0.0001, sustain, sustain/2, 0.3), gate,
doneAction:2);
b1 = 1.987 * 0.9889999999 * cos(0.09);
b2 = 0.998057.neg;
signal = SOS.ar(K2A.ar(t_trig), 0.3, 0.0, 0.0, b1, b2);
signal = RHPF.ar(signal*0.8, freq, rq) + DelayC.ar(RHPF.ar(signal*0.9,
freq*0.99999, rq*0.999), 0.02, 0.01223);
signal = Decay2.ar(signal, 0.4, 0.3, signal);
Out.ar(out, (signal*env)*(amp*0.65)!2);
}).add;


Pbind(\instrument, \marimba, \freq, Pseq([60, 67, 63, 58], inf).midicps,
\dur, 0.5, \amp, 0.6).play


SynthDef(\wood, {arg out=0, amp=0.3, pan=0, sustain=0.5, t_trig=1, freq=100,
rq=0.06;
var env, signal;
var rho, theta, b1, b2;
b1 = 2.0 * 0.97576 * cos(0.161447);
b2 = 0.9757.squared.neg;
signal = SOS.ar(K2A.ar(t_trig), 1.0, 0.0, 0.0, b1, b2);
signal = Decay2.ar(signal, 0.4, 0.8, signal);
signal = Limiter.ar(Resonz.ar(signal, freq, rq*0.5), 0.9);
env = EnvGen.kr(Env.perc(0.00001, sustain, amp), doneAction:2);
Out.ar(out, Pan2.ar(signal, pan)*env);
}).add;


Pbind(\instrument, \wood, \freq, Pseq([60, 67, 63, 58], inf).midicps, \dur,
0.5, \amp, 0.6).play

RHPF