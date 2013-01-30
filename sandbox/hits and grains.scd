// Hits buffers
~bfs = SoundFile.collectIntoBuffers("/Volumes/Mega/projects/timmer/samples/banks/hits/*");

// Decimated sin + KB hits
SynthDef(\sinTest, { arg bufnum, freq, amp, dur, fb=0.1, attack = 1, release=1, gate=1, lpf=8000, hpf=5;
    var out = Decimator.ar(SinOscFB.ar(freq, fb * 1), 48000, 7, amp) * EnvGen.kr(Env.adsr(attack, dur, 1, releaseTime:release, curve:-24), gate, doneAction:2);
    out = (0.5 * out) + HPF.ar(LPF.ar(Mix(PlayBuf.ar(2, bufnum)).dup * EnvGen.kr(Env.perc(releaseTime:1.min(dur+release))) * 8, lpf), hpf);
    Out.ar(0, out)
}).add;


// Bass overtone frequencies
~freqs = (1..12).collect { arg i; i * ([28,33,38,43].midicps) }.flop;

// Make scale from frequencies - closest possible from equally tempered scale
(
var root = 28;
var r = ~freqs.cpsmidi.flatten.wrap(0+root, 12+root).sort - root;
r.postln;
~tuning = (0..11).collect({ arg i;
    r[r.indexIn(i)].postln;
});
a = Scale.new(#[0,2,3,5,7,9,11], 12, Tuning.new(~tuning))
)

// Groove
(
z.stop;
z = Ppar([
    Pbind(\instrument, \sinTest,
        \root, Pseq([4, -1], inf).stutter(Pwhite(12, 18)),
        \degree, Pseq([[7,4+7,2+7], [6, 4+7, 3+7]], inf).stutter(6),
        \scale, a,
        \dur, Pseq([20, 20.fib(1,2), 1].convertRhythm.max(0.03), inf),
        \legato, 1,
        \release, 2,
        \octave, Pwhite(3,4),
        \bufnum, Pfuncn ({ ~bfs.choose } , inf),
        \lpf, 19, \hpf, 120, \fb, Pwhite(0, 0.4)).play,


    Pbind(\instrument, \sinTest, \root, 4, \degree, 0, \scale, a, \dur, Pwrand([1, 2], [10, 4].normalizeSum, inf), \lag, Pbrown(-0.1, 0.1, 0.05), \legato, 0.5, \lpf, 200, \octave, 2, \bufnum, Pfuncn ({ ~bfs.choose } , inf), \amp, 0.01),

    Pbind(\instrument, \sinTest, \root, 4, \degree, Pxrand([0,1,3,4], inf), \scale, a, \dur, 5, \lag, Pbrown(-0.1, 0.1, 0.05), \legato, 1, \release, 2, \hpf, 4000, \lpf, 2000, \octave, 5, \bufnum, Pfuncn ({ ~bfs.choose } , inf), \fb, Pwhite(0.0, 0.2)),
]).play
)

// Extra melody
f.stop;
f = Pbind(\instrument, \sinTest, \root, 4, \degree, Pxrand([4,6,7], inf), \scale, a, \dur, Pwhite(2, 6), \lag, Pbrown(-0.1, 0.1, 0.05), \legato, 0.01, \release, 6, \lpf, 50, \octave, 6, \bufnum, Pfuncn ({ ~bfs.choose } , inf), \fb, 0.45, \amp, 0.01).play

s.makeWindow

// ----------------------------------------------------------
// ----------------------------------------------------------

// Single flageolet hit granular pad

b = 2. collect { |i| i.postln; Buffer.readChannel(s, "/Volumes/Mega/projects/timmer/render/to SC/flageolett-test.wav", channels: [i]) }

c = 2. collect { |i| i.postln; Buffer.readChannel(s,
"/Volumes/Mega/projects/timmer/render/to SC/flageolett-test2.wav", channels: [i]) }

d = 2. collect { |i| i.postln; Buffer.readChannel(s, "/Volumes/Mega/projects/timmer/render/to SC/flageolett-test3.wav", channels: [i]) }
e = 2. collect { |i| i.postln; Buffer.readChannel(s, "/Volumes/Mega/projects/timmer/render/to SC/flageolett-test4.wav", channels: [i]) }


(

{
    var snd = Mix.panSpread(2.collect { |i| GrainBuf.ar(1, Dust.ar(2), 1.6, d[i], pos: (WhiteNoise.ar.range(0, 0.6)).poll) }  * 0.4, width:0.2);

    HPF.ar(Compander.ar(snd, HPF.ar(snd, 3000), 0.0001, 10, 1, 0.002, 0.1), 400)

    }.play
)

// This is probably the one we want
(
x.free;
x = {
    var trig = Dust.ar(20);
    2.collect { |i| HPF.ar(LPF.ar(Mix.panSpread(2.collect { |i| GrainBuf.ar(1, trig, 0.9, e[i], LFPulse.ar(20, add: TIRand.ar(1, 2, trig)) * 0.5, pos: (WhiteNoise.ar.range(0, 0.6))) } * 8, width:2), 2000), 500) } * 10 /*+ Pan2.ar(HPF.ar(trig, TExpRand.ar(200, 20000, trig)), 0.7, 0.03)*/

    }.play
)
// ---------------------------------


// Some trash
(
{
    2.collect { |i| GrainBuf.ar(1, Impulse.ar(30), 0.2, b[i], 2, pos: (WhiteNoise.ar.range(0, 0.1)).poll) }

    }.play
)