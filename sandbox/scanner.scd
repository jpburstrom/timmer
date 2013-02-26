d = [0,1].collect( { |ch| Buffer.readChannel(s, "/Volumes/Mega/projects/timmer/render/to SC/mollackord-130224.wav", channels: [ch]) })

e = [0,1].collect( { |ch| Buffer.readChannel(s, "/Volumes/Mega/projects/timmer/samples/banks/hits/hits-3.wav", channels: [ch]) })

d.play
(

SynthDef(\scanner, { | buffers=#[0,1], out=0, freq = 50, amp=0.8, speed = 0.01, gate=1, startPos = 0, envbufnum = -1, attack=0.01, decay = 0.3, sus = 1, release = 0.1 |
    var trig, noise, pos, ljud, len, origfreq;
    origfreq = freq;
    freq = freq * (1 - speed);
    trig = Impulse.ar(freq);
    noise = 0;
    len = BufFrames.kr(buffers[0]) / BufSampleRate.kr(buffers[0]);
    pos = Line.ar(startPos, dur: (len - startPos) / speed) + (WhiteNoise.ar(freq.reciprocal * noise.cubed));
    ljud = GrainBuf.ar(1, trig, freq.reciprocal * 2, buffers, 1, pos, envbufnum: envbufnum);
    // ljud = ljud + SinOsc.ar(origfreq, mul: 0.1);
    // ljud = OpLPF.ar(ljud, 440);
    Out.ar(out, LeakDC.ar(ljud * EnvGen.kr(Env.adsr(attack, decay, sus, release), gate, amp, doneAction: 2)));
    }
).add




)

c = Buffer.sendCollection(s, Signal.rectWindow(1024).asWavetable);

Synth(\scanner, [\buffers, d]).play
ScaleInfo.scales
(instrument:\scanner, buffers:d).play
(
Pbind(
    \octave, 3,
    \scale, Scale.hexMajor7,
    \dur, Prewrite(Pseq([0.2, 0.4], 1), (0.2: [0.2, 0.4, 0.2], 0.4: [0.2, 0.6], 0.6: [0.1,0.3]), 6),
    // \dur, 0.03,
    \buffers, [d],
    \instrument, \scanner,
    \db, #[6, -12],
    \release, Pkey(\dur) * 2,
    \attack, 0,
    \envbufnum, Pwrand([-1, c], [0.9, 0].normalizeSum, inf), // [-1, -1, -1],
    \startPos, Pseg([0.2, 0.1, 0.2], Pwhite(1.0, 5), repeats:inf),
    \speed, 0.025,
    \degree, Pstutter(Pseries(0, 4).fold(4, 12), Pseries(0, 3).fold(0,8).clump(3) + Pfunc({[8, 0, 0 ].scramble})),
    \degree, 0,
    \speed, Pseg([0.01, 0.02, 0.01], 5, repeats:inf), //Prand([0.01, 0.2, 0.3, 0.5], inf),
    \midinote, #[ -7, 49],
    \lag, Pwhite(-0.01, 0.01),
    \legato, 1,
    // \hardness, Plprand(10, 100)
).play
)
0.01.midiratio
.ratiomidi
2.2.asQuaternion
"Eb2".namemidi
42.midiname
d.play
Note.calculate(midi:2)
SimpleNumber