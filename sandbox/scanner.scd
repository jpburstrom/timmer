d = [0,1].collect( { |ch| Buffer.readChannel(s, "/Volumes/Mega/projects/timmer/samples/mollackord.wav", channels: [ch]) })

d.play
(

SynthDef(\scanner, { | buffers=#[0,1], out=0, freq = 50, amp=0.8, hardness = 10, speed = 0.01, gate=1, startPos = 0, envbufnum = -1, attack=0.01, decay = 0.3, sus = 1, release = 0.1 |
    var trig, noise, pos, ljud, len;
    trig = Impulse.ar(freq);
    noise = 0.1;
    len = BufFrames.kr(buffers[0]) / BufSampleRate.kr(buffers[0]);
    pos = Line.ar(startPos, dur: (len - startPos) / speed) + (WhiteNoise.ar(freq.reciprocal * noise.cubed));
    ljud = GrainBuf.ar(1, trig, freq.reciprocal * 2, buffers, 1, pos, envbufnum: envbufnum);
    Out.ar(out, LeakDC.ar(ljud * EnvGen.kr(Env.adsr(attack, decay, sus, release), gate, amp, doneAction: 2)));
    }
).add




)

c = Buffer.sendCollection(s, Signal.rectWindow(1024).asWavetable);

Synth(\scanner, [\buffers, d]).play

(instrument:\scanner, buffers:d).play
(
Pbind(
    \octave, 3,
    \scale, Scale.melodicMinor,
    \dur, Pwhite(0.5, 2.0),
    \buffers, [d],
    \instrument, \scanner,
    \db, -9,
    \release, 0,
    \attack, 0,
    \envbufnum, -1,
    \startPos, 0,
    \speed, 0.025,
    \degree, 0,
    \legato, 1,
    \hardness, Plprand(10, 100)
).play
)

4.collect({Array.rand(3, 0, 8)})

(Pkey(\startPos) == 0)
