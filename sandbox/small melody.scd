P3n1(Pn(10, 1), 1).asStream.nextN(15)

SynthDef(\sinefb, { |freq=440, gate=1, sustain=0| Out.ar(0, SinOscFB.ar(freq, 0, mul:0.1) * EnvGen.kr(Env.linen(0, sustain, 0.2), gate, doneAction:2)) } ).add

(

p = Pbind(\instrument, \sinefb, \legato, 1, \x, P3n1(Pseq((1, 3..11)), 1), \dur, (1 / P3n1(Pseq((3, 5..13)), 1).wrap(1, 8)) * 2, \note, (Pkey(\x) + 0).wrap(-7, 11));

)

p.play

Synth(\default).autogui