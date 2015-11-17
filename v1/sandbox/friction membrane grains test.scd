(
//Timmer.grainmono - basic mono single-grain player.
SynthDef("timmer.grainmono", { arg start, sustain, bufnum, rate = 1, pan = 0, amp = 1, attack = 0.001, decay = 0.02, outbus;
	var env, snd;
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
    start = (start * BufFrames.kr(bufnum));
    attack =
	snd = PlayBuf.ar(1, bufnum, rate * BufRateScale.kr(bufnum), 1, start, 1)
		* EnvGen.kr(Env.linen(attack, sustain, decay, 1, \sine), doneAction: 2);
	OffsetOut.ar(outbus, Pan2.ar(snd, pan, amp))
}).add;


b = Buffer.read(s, "/Volumes/Mega/projects/timmer/samples/test/hits2.wav")

)


(

x.free;
Pspawner({ arg sp;
    loop {
        sp.seq(
            Pbindef(\test)
        );
        sp.seq(
            Pbindef(\wait)
        )
    }
}).play;

x = { var snd = In.ar(c, 2); snd = MembraneCircle.ar(snd, 0.005, 0.9999) * 0.1 ; Out.ar(0, snd) }.play

)
)
g = Group.tail
(
x.free;
x = { var snd = In.ar(c, 2); snd =
    DFM1.ar(
        MembraneCircle.ar(snd, 0.0112 * LFNoise1.ar(10, 0.02, 1), 0.999, -36.dbamp),
        35, 0.0, 1, 1,
        noiselevel:0.0001);
    snd = SmoothDecimator.ar(snd, 6000, 0.8);
    Out.ar(0, snd) }.play(g);
)
SmoothDecimator
(

Pbindef(\test,
    \instrument, 'timmer.grainmono',
    \bufnum, b,
    \dur, Pwhite(0.001, 0.1),
    \legato, 1,
    \start, Pwhite(0, 1.0),
    \amp, Pseg(Pseq([1, 0.01]), 1, \exp),
    \attack, 0.02,
    \decay, 0.1,
    \addAction, 0,
    \outbus, c,
    \pan, Pwhite(-0.2, 0.2)
);

Pbindef(\wait,
    \dur, Pwhite(1.2, 2.5, 1),
    \type, \rest
);

Pbindef(\test, \amp, Pconst(30, Pexprand(0.01, 1.8)));

)

{ Out.ar(c, SoundIn.ar([0, 1], c)) }.play



(
x.free;
x = { LeakDC.ar(Friction.ar(SoundIn.ar(0), 0.002, 0.014, 0.113, 1.5, 1)) }.play
)

(
// Some Ringz oscillators, each with a _separate_ Friction1, then merged to create a "rusty" klank.
// Note the way the effect changes as the sound dies away.
x = {
var imp, klank, rusty;
imp = Impulse.ar(1, 0, 0.1);
klank = Ringz.ar(imp, [800, 1071, 1153, 1723]);

rusty = Friction.ar(klank,
friction: 1.75584e-5,
mass: 6.69789);

Pan2.ar(rusty.sum)
}.play(s);
)
