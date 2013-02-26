b = Buffer.read(s, "/Volumes/Mega/projects/timmer/creations/bryggen-20110519/01-Stall-110519_1550.wav")
(
~markers = File.use("/Volumes/Mega/projects/timmer/analysis/glömskan-solo.txt", "r",
    { arg f;
        var z = [];
        f.readAllString.split($\n).collect(_.split($ ).asFloat).flop[0]
    }
)
)

~times = ~markers.differentiate.drop(1);
~markers = ~markers.drop(-1);

~times[100]

~markers[101] - ~markers[100]

SynthDef(\fxMembraneBanjo, { arg bus;
    var snd = In.ar(bus);
    snd = MembraneCircle.ar(snd, 0.065, 0.992).softclip;
    snd = Median.ar(9, snd);
    Out.ar(0, snd.dup * 4);
}).add;

(
x.free; c.free;
c = Bus.audio;
x = Synth(\fxMembraneBanjo, [\bus, c]);
y = { Out.ar(c, PlayBuf.ar(1, b, 1, 1, 128000)) } .play
y.free;
)

~times


(
SynthDef(\sampleMembraneMarkerPlayer, { |bufnum, pos, dur, bufrate=1, amp=1, fade=0.01|
    var snd = PlayBuf.ar(1, bufnum, bufrate * BufRateScale.kr(bufnum), 1, BufSampleRate.kr(bufnum) * pos);
    snd = EnvGen.ar(Env.perc(0, Rand(0.2, 1.5))) * snd;
    snd = MembraneCircle.ar(snd, 0.065, 0.992).softclip;
    snd = snd * EnvGen.ar(Env.linen(fade, dur, fade, amp, \sin), doneAction:2);
    snd = Median.ar(9, snd);
    Out.ar(0, snd.dup);
}).add;
)
(
SynthDef(\sampleMarkerPlayer, { |bufnum, pos, dur, bufrate=1, amp=1, fade=0.01|
    var snd = PlayBuf.ar(1, bufnum, bufrate * BufRateScale.kr(bufnum), 1, BufSampleRate.kr(bufnum) * pos);
    // snd = MembraneCircle.ar(snd, 0.005, 0.999).softclip;
    snd = snd * EnvGen.ar(Env.linen(fade, dur, fade, amp, \sin), doneAction:2);

    Out.ar(0, snd.dup);
}).add;
)
(
Pbind(\instrument, \sampleMembraneMarkerPlayer,
    \bufnum, b,
    \startIndex, Pseries(0, Pwrand([1, 89], [5,0].normalizeSum, inf).trace, inf).wrap(83, 262), // First part
    \fade, 0.01,
    \bufrate, 2,
    // \bufrate, Prand(([0]).midiratio, inf),
    \pos, Pfuncn({|ev| ~markers[ev.startIndex] - ev.fade}, inf),
    // \delta, Prand([0.25, 0.5], inf),
    \dur, Pfuncn({|ev| (1 * ~times.drop(ev.startIndex).keep(1).sum) - ev.fade}, inf),
    \amp, 1
).play(quant:1);
Pbind(\instrument, \sampleMarkerPlayer,
    \bufnum, b,
    \startIndex, Pseries(0, Pwrand([1, 89], [5,0].normalizeSum, inf).trace, inf).wrap(83, 262), // First part
    \fade, 0.01,
    \bufrate, 1,
    // \bufrate, Prand(([0]).midiratio, inf),
    \pos, Pfuncn({|ev| ~markers[ev.startIndex] - ev.fade}, inf),
    // \delta, Prand([0.25, 0.5], inf),
    \dur, Pfuncn({|ev| (1 * ~times.drop(ev.startIndex).keep(1).sum) - ev.fade}, inf),
    \amp, 1
).play(quant:1);
)


(
Pbind(\instrument, \sampleMarkerPlayer,
    \bufnum, b,
    \startIndex, Pseries(0, Pwrand([1, 89], [5,1].normalizeSum, inf).trace, inf).wrap(83, 262), // First part
    \fade, 0.01,
    // \bufrate, 1,
    \bufrate, Prand(([0]).midiratio, inf),
    \pos, Pfuncn({|ev| ~markers[ev.startIndex] - ev.fade}, inf),
    \delta, Prand([0.25, 0.5], inf),
    \dur, Pfuncn({|ev| (1 * ~times.drop(ev.startIndex).keep(1).sum).min(ev.delta).max(ev.delta) - ev.fade}, inf),
    \amp, 0.25
).play(quant:1);

Pbind(\instrument, \sampleMembraneMarkerPlayer,
    \bufnum, Pseq([b, Rest(0.25)], inf).stutter(Pseq([Pwhite(10, 15), 1])).trace,
    \startIndex, Pseries(0, Pwrand([-2, 89], [5,1].normalizeSum, inf).trace, inf).wrap(83, 262), // First part
    \fade, 0.01,
    \bufrate, Prand((12 + [0, 5]).midiratio, inf),
    \pos, Pfuncn({|ev| ~markers[ev.startIndex] - ev.fade}, inf),
    \delta, Prand([0.125, 0.25], inf),
    \dur, Pfuncn({|ev| (1 * ~times.drop(ev.startIndex).keep(1).sum).min(ev.delta).max(ev.delta) - ev.fade}, inf),
    \amp, 1
).play(quant:1)
)

0.midiratio
