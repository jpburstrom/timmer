//# Template for songs ###

//## Initialize ###
(
"lib/init".import;
q.player.actionLabels = #[onset];
q.player.tickLabel = \onset;
q.player.loadData("08");
//q.player.extractFeatures;
q.playerui.connect(q.player)
// q.markov = "/lib/protos/markov-trainer".import;
)

(
var handClapPaths = "samples/handclaps/*.wav".resolveRelative;
//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar
q.player.onReady = {
	~t.handclaps = handClapPaths.pathMatch.collect { |path|
		Buffer.read(s, path);
	}
};
q.player.data.grouping = #[
	//Part one, onset groups
	[ 0, 1, 2, 3, 1, 4, 5, 1,
        6, 7, 1, 7, 8, 9, 7, 10,
        7, 11, 12, 13, 7, 12, 14, 9,
        15, 7, 12, 14, 16, 17 ]
];
q.player.data.iterators = ().make {
	//Scramble order of first part, but don't put two in the same group after each other
	~p1 = Plazy { Pseq(Fdef(\scrambleAvoidSimilar).(q.player.data.grouping[0])) } ;
	~p2 = Pseries(30, 1, 34);
	~p3 = Plazy {
		Pseq((64..76).scramble)
		++ Pseq((77..80))
		//This is a bit
        ++ Pwalk((81..90), Pwrand([-2, 1, 2], [0.3, 0.4, 0.4], 30.rrand(50)))
	};
	// ~p4 = Pn(91,1) ++ Pxrand((92..104), 24) ++ Pn(105, 1);
	~p4 = Pseq((91..105));
	~p5 = Pseq((106..301));
	//Break it down
	~p6 = Pseries(302);
	// ~p7 = Pn(0);
};
)
)

(
//## Patterns #######

//This sets a pattern used to modify the base player pattern.
q.player.setPtn(Plazy({
	var endSegment = 360.rrand(370);

	Pbind(
		\startPos, Pkey(\startPos) - 0.002,
		\dummy, Prout({ |ev|

			var claps = Pn(Plazy { Pseq(~t.handclaps.scramble) }).asStream;
			var blacklist = (118..122) ++ (134..139) ++ (175..186) ++ (192..199);

			var endDuration = 40.rrand(55);

			while ({ev.onset < 105}) { ev = 0.yield };

			while ({ev.onset < 218}) {
			if ( blacklist.includes(ev.onset).not and: { 0.7.coin } ) {
			(instrument:\bufSegment, bufnum: claps.next, amp:1).play;
			};
			ev = 0.yield
			};

			while ({ev.onset < 301}) {
			ev = 0.yield;
			};

			~spawner.par(Pbind(
			\instrument, \bufSegment,
			\bufnum, Pfunc { claps.next  },
			\amp, Pbrown(0.2, 0.5),
			\dur, Fdef(\pFuzzyBeatMatch).(q.player.data.onset[301..368].flop[1], 5);
			));


			//while playing through, yield zero
			//Then advance to the next pattern in the Pseq
			while ({ev.onset <= endSegment}) {
				ev = 0.yield;
			};

			//Parallell pattern, which continues after the main pattern has been silenced
			//(see below)
			~spawner.par (
				Pfindur(endDuration + ev.dur, Pchain(
					Pbind(
						\instrument, \bufSegmentPlankS,
						\startPos, Pxrand(~data.onset.flop[0], inf),
						\amp, Pkey(\amp) * 2,
						\test, Pfunc { "hello".postln },
						\pan, 0.2,
					),
					Pdef(\t08randomizedBeginning)
				))
			);

			//Silence this, but continue running until `t08RandomizedBeginning` stops
			//FIXME: This doesn't really work
			Pfindur(endDuration, Pfunc { |ev|
				0
			}).embedInStream(ev);

		}),
		//TEMP: Shorten last non-freqshifted note, so we don't get start of next attack
		\dur, Pif(Pkey(\onset) == (endSegment), Pkey(\dur) - 0.05, Pkey(\dur)),
		\instrument, Pif(Pkey(\onset) < 370, \bufSegment, \bufSegmentFreqshift),
		\freqshift, -5000.rrand(-8000);
	)

}));
//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(Plazy { Psym(Pseq(#[p1, p2, p3, p4, p5, p6]), ~data.iterators) });
q.player.play
)
q.player.stop

q.player.currentEvent
//TESTS
q.player.bounce
s
q.player.trace = false

~buf8 = Buffer.read(s, "../songs/08-Burk korta 2 ___-44100.wav".resolveRelative);
~grainBuf = Buffer.alloc(s, 44100, 1);

(
Ndef(\fqShiftTest8, {
    //Frequencies as multiples of EADG
    var freqs = ["E0", "A0", "D1", "G1"].namecps *.x [-5, -7, -11];
    var fadetime = 0.002;
    var sustain = 3.3;
    var snd2, snd = PlayBuf.ar(2, ~buf8, BufRateScale.kr(~buf8), startPos:0 * 44100);
    var chain = FFT(LocalBuf(512), snd[0]);
    //every onset has a probability of 0.1 to trigger a new chosen frequency
    var singletrig = Onsets.kr(chain, 0.1);
    var trig = Impulse.kr(0) + CoinGate.kr(0.1, singletrig);
    var freq = Latch.kr(LFNoise2.kr(0.05).exprange(-2000, -8000), trig);
    var lin = LocalIn.ar(2);

    var flag, flag2;

    var dronefreq, dronefreqs = ((0..11) + 36).midicps * 3;

    //Delay to compensate for late onset detection
    snd = DelayN.ar(snd, 0.1, 0.095);

    //Treat a single harmonic
    flag = BPF.ar(snd, 490, 0.01);
    flag = Mix.fill(3, { FreqShift.ar(flag, LFNoise2.ar(0.1).range(-10, 10), mul:1) });

    snd2 = FreqShiftAA.ar(snd, freq) * 24.dbamp;
    snd2 = Compander.ar(snd2, snd2, 0.01, 10, 0.1, 0.01, 0.5);

    snd2 = DelayC.ar(snd2, 0.1, LFNoise2.ar(0.1).range(0,0.05));


    lin = DelayC.ar(LPF.ar(snd2 + lin, 1000), 1, LFSaw.ar(0.33).exprange(1.5, 0.0001), 0.5);

    lin = Balance2.ar(lin[0], lin[1], -0.33);

    LocalOut.ar(LeakDC.ar((lin * 10).tanh * 0.1));

    // snd = LinSelectX.ar(K2A.ar(TIRand.kr(0, 12, singletrig) < 1).lagud(0.5, 0.05).poll, [snd, FreqShiftAA.ar(snd, MouseX.kr(0, -4000))]);

    dronefreq = \dronefreq.kr([100, 120], 0.1);
    // dronefreq = LFNoise2.ar(1).range(100, 200).lag(0.2);
    // dronefreq = 100;


    snd = snd + Mix(LPF.ar(CombC.ar(BBandStop.ar(snd, dronefreq), 0.2, dronefreq.reciprocal, LFNoise2.kr(0.3).range(-0.1, EnvGen.kr(Env([-20, -20, -0.2], [0, 10], \exp), \combTrig.kr(1)))), LFNoise2.kr(0.5).exprange(100, 200), 0.1)).dup;

    snd = snd + lin;

    flag + snd;

    // flag2

}).play
)

(0..11).choose !2

Ndef(\fqShiftTest8).set(\dronefreq, {((0..11) + 36).midicps.choose}.dup(2) * 3)

Ndef(\fqShiftTest8).set(\combTrig, 0);
Ndef(\fqShiftTest8).set(\combTrig, 1);









