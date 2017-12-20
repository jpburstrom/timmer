~seed = 1234;
(
SynthDef(\setSeed, { |seed|
    RandSeed.kr(Impulse.ar(0), seed);
}).add;

SynthDef(\randSine, { |freq, amp, gate(1), out(0), id(0)|
    var snd = SinOscFB.ar(freq, LFNoise2.kr(0.2).range(0, 1), amp);
    LFNoise2.kr;
    RandID.ir(id);
    snd = snd * Env.asr(0.01, 1, 0).kr(2, gate);
    Out.ar(out, snd)
}).add
)

(
{
var x = Synth(\setSeed, [\seed, ~seed]);
1.wait;
x.free;

}.fork;
thisThread.randSeed = ~seed;
Pbind(\instrument, \randSine, \note, Pwhite(0,11), \dur, Pn(0.25, 10), \legato, 2, \id, Pseries() % 16).play
)