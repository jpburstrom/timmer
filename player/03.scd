//# Template for songs ###

//## Initialize ###
(
var handClapPaths = "samples/handclaps/*.wav".resolveRelative;
var impulsePath = "data/impulses/impulse-closed-ms-48.wav".resolveRelative;

"lib/init".import;
q.player.actionLabels = #[onset];
q.player.tickLabel = \onset;
q.player.loadData("03");

//q.player.extractFeatures;
// q.playerui.connect(q.player);

q.player.onReady = {

	~t.mainBus = Bus.audio(s, 2);
	~t.delayBus = Bus.audio(s, 2);

	~t.ez = EZConv(impulsePath);
	~t.convBus = Bus.audio(s, 2);
	s.sync;

	 /*
	~t.conv = Synth(\msConv, [\inbus, ~t.convBus, \outbus, 0, \irbufs, ~t.ez.irSpectrum,
		\sideAmp, 1, \amp, 0.25
	], ~t.sendGroup);

   ~t.synth1 = {
        var freq= 84*2;
        var snd = BPF.ar(In.ar(~t.mainBus, 2) * 4, freq, LFNoise2.kr(0.1).range(0.002, 0.001)) * SinOsc.ar(LFNoise2.kr(0.2).exprange(120, 130));
        snd = CombC.ar(snd, 0.05, freq.reciprocal, 5);
        snd = DelayC.ar(snd, 0.1, LFNoise2.ar(0.2).range(0,0.01));
		Out.ar(~t.convBus, snd); //Send to convolution
        snd
    }.play(~t.postGroup);
	*/

    /*
	~t.fqshift = Synth(\freqShift, [\inbus, ~t.mainBus, \outbus, ~t.delayBus, \freq, -5000, \amp, 1, \midAmp, 0.2], ~t.postGroup);

	~t.delay = {
		var snd = In.ar(~t.delayBus, 2);
		snd = snd + AllpassC.ar(snd, 0.21, 0.21, 0.1, 0.25);
		snd
	}.play(~t.fqshift, addAction:\addAfter);

	~t.mixin = {
		In.ar(~t.mainBus, 2) * 0.5
	}.play(~t.sendGroup);

    */
};

//## Patterns #######

//This sets a pattern used to modify the base player pattern.
q.player.setPtn(Pbind(
	\out, Pfunc { ~t.mainBus; 0 },
    \timingOffset, 0.1,
    \legato, 1,
    \type, Pseq([\rest, Pn(\note, inf)])
    // \dur, Pkey(\dur) * Pwrand([0.1, 1], [0.1, 0.9], inf)
    // \dur, Pkey(\dur) * Pseg(Pwhite(0.8, 1), 4)
));



q.player.parPtn = Ptpar([0.1, Pbind(
	\instrument, \bufSegmentPlank,
    \bufnum, Pfunc { ~protoEvent.bufnum },
    \index, Pfunc { ~currentEvent.onset.rand }, //Randomize among already played onsets
    \startPos, Plazy({ var times = ~data.onset.flop[0]; Pfunc { |ev| times[ev.index] } }),
    \totalDur, p { var dur = ~data.onset.last[0]; loop { dur.yield } },
    \freqPtnLength, Pseg([50, 1], Pkey(\totalDur)),
    //Choose 5 new overtones of E1 and F1, A1 every 25-50
    \freq, Pclump(Pwrand([1,2], [0.9,0.1], inf),
        Pn(Plazy { |ev| Prand(([40, 41, 45].midicps *.x (2..8)).select(_ > 200).scramble.keep(5), ev) })),
    \pan, Pkey(\freq).wrap(-0.4, 0.4),
    \sustain, Pkey(\freq).wrap(1, 3) * Pwhite(0.5, 1),
    //Divide overtones
    //TODO: Balance density/duration
    \divisions, Pwhite(1, Pseg([5,1.5,5,1.5,3], Plazy { Pseq([[0.5, 1], [4.0, 6], [2.0, 5], [1.0, 9.0]].collect(_[0].rrand(_[1])).normalizeSum) } * Pkey(\totalDur)).trace),
    \dur, PdurStutter(Pkey(\divisions).round, Pfunc { |ev| ~currentEvent.dur }),
    // \dur, Pfunc { |ev| ~currentEvent.dur },
	\group, Pfunc { ~t.mainGroup },
    \timingOffset, Plprand(0.0, 0.05),
    \strum, Pif(p { arg ev;
        var prev, test;
        loop {
            test = (ev.freq == prev);
            prev = ev.freq;
            ev = test.yield;
        }
    }, 0, Pwhite(0.05, 0.1)),
    \amp, p { |ev|
        var amp, rest;
        loop {
            30.rrand(100).do {
                ev = 1.yield;
            };
            0.rrand(30).do {
                ev = \rest.yield
            }
        }
    },
    \out, 2
)]);
//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(Pseries(0));
//q.player.play
)
/*
Ndef(\testtone).prime({ SinOscFB.ar(\freq.kr(84), \fb.kr(0.0) ).dup * \amp.kr(0.1) })

Ndef(\testtone).gui
*/

q.player.bounce((dur:10))
