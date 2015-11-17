~buf = Buffer.read(s, "/Volumes/Mega/projects/timmer/samples/Brygga-Loop*".pathMatch.last);
~rec = Buffer.alloc(s, 48000*120, 2);
(
SynthDef(\samplePlayerTest, { |bufnum, pos, sustain, bufrate=1, amp=1, fade=0.01, freqShift=100|
    var snd = PlayBuf.ar(1, bufnum, bufrate * BufRateScale.kr(bufnum), 1, BufFrames.kr(bufnum) * pos, 1);
    //snd = EnvGen.ar(Env.perc(0, Rand(0.2, 1.5))) * snd;
    //snd = MembraneCircle.ar(snd, 0.065, 0.992).softclip;
    snd = snd * EnvGen.ar(Env.linen(fade, sustain, fade, amp, -4), doneAction:2);
    //snd = Median.ar(9, snd);
    4.do { snd = HPF.ar(snd, freqShift) };
    snd = FreqShift.ar(snd, freqShift * -1);
    Out.ar(0, Pan2.ar(snd, Rand(-0.1, 0.1)));
}).add;
)

(
~grp = Group();
Pbind(
    \instrument, \samplePlayerTest,
    \bufnum, ~buf,
    \bufrate, 1,
    \legato, 2,
    \fade, 0.2,
    \db, -12,
    \dur, Pwhite(0.01, 0.3),
    \pos, Pwhite(0, 1.0),
    \group, ~grp,
    \freqShift, Pwhite(5000, 15000),
    \addAction, \addToHead
).play;
//~test = { RecordBuf.ar(In.ar(0, 2), ~rec); PlayBuf.ar(2, ~rec, 0.97) }.play(~grp)
)

~test.free

~test2 = 2.collect { { PlayBuf.ar(2, ~rec, rrand(0.92, 0.99)) }.play(~grp, addAction:\addToTail) }

{ ReplaceOut.ar(0, HPF.ar(In.ar(0, 2), 600)) }.play(addAction:\addToTail)

(
~foo.free;
~foo = {
    var x = [100, LFNoise2.ar(0.1).exprange(1000, 1100)];
    var z = Mix(In.ar(0, 2));
    x.postln;
    ReplaceOut.ar(0, Splay.ar(
        x.collect { arg y;


        })
        + (In.ar(0,2) * 0.3))
}.play(addAction:\addToTail)
)
~foo.free