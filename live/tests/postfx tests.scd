
//VERB
y = {
    JPverb.ar(In.ar(0), 5, 0, 2) * (PinkNoise.ar(0.05))
}.play(q.tree.mstfxgrp);

y.play
y.free

//Freqshift
//Funkar ganska bra att köra från SoundIn
//Ehrlund-miken vore bättre?
b = Buffer.alloc(s, 480000);
x = {
    var snd = FreqShift.ar(DelayC.ar(HPF.ar(SoundIn.ar(0), 55), 5, 0.01), -55) * 4;
    snd = LPF.ar(snd, 440);
}.play(q.tree.mstfxgrp)

x.free
In.ar

