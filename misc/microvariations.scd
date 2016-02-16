~buf = Buffer.read(s, "/Volumes/HD2/projects/timmer-2015/render/01-Preparerad flageolett 2 ___-44100.wav");
~onsets = TabFileReader.read("/Volumes/HD2/projects/timmer-2015/kod/player/data/01/onset.txt").flop[0].collect(_.asFloat);
~durations = ~onsets.differentiate[1..];
~segment = 0;

(

SynthDef(\varTest, { |bufnum, startPos, sustain(0), bufRate(1)|
    var snd, attack, release, fadetime = 0.002;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0); //Convert seconds to samples
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * bufRate, startPos: startPos);
    attack = LPF.ar(snd, ExpRand(10, 20000)) + (PinkNoise.ar(ExpRand(0.001, 0.02)));
    release = (snd + (snd * SinOsc.ar(ExpRand(30, 400), mul: ExpRand(0.01, 0.3)))) * EnvGen.ar(Env.asr(ExpRand(0.001, 0.2)));
    snd = SelectX.ar(Line.ar(0, 1, 0.05), [attack, release]);
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    Out.ar(\outbus.kr(0), snd);
}).add;
)

var segment = 2; Synth(\varTest, [\buf, ~buf, \startPos, ~onsets[segment] + 0.01, \sustain, ~durations[segment]])

(
Pdef(\varTestTest, Pbind(
    \instrument, \varTest,
    //\delta, 1,
    \legato, 1,
    \segment, Pseries().wrap(0, 32),
    \dummy, Pfunc({ |ev|
        ev.startPos = ~onsets[ev.segment];
        ev.dur = ~durations[ev.segment];
    });
)).play;
)