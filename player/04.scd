//# Template for songs ###

//## Initialize ###
(
"lib/init".import;
q.player.actionLabels = #[phrase, part];
q.player.tickLabel = \phrase;
q.player.loadData("04");
//q.player.extractFeatures;
q.playerui.connect(q.player);
q.markov = "lib/protos/markov-trainer".import;
q.markov.setBounds(q.player.data.lookup.part[2], q.player.data.lookup.part[3] - 1);
q.markov.connect(q.player);
q.markov.initChain;
)

q.markov.chain.collectAs({ |x| var index = x[0].indexOf(32); index !? { x[1][index] }  }, Array).reject(_.isNil)
nil ?? 2

~buf4 = Buffer.read(s, "songs/04-Qin 2 __-44100.wav".resolveRelative);

//### HELLO TEST ###
(
Ndef(\fqShiftTest, {
    //Frequencies as multiples of EADG
    var freqs = ["E0", "A0", "D1", "G1"].namecps *.x [-5, -7, -11];
    var fadetime = 0.002;
    var sustain = 3.3;
    var snd = PlayBuf.ar(2, ~buf4, BufRateScale.kr(~buf4), startPos:44100*11.56);
    var chain = FFT(LocalBuf(512), snd[0]);
    var trig = Onsets.kr(chain, 0.2);
    //every onset has a probability of 0.1 to trigger a new chosen frequency
    var randFreq = Demand.kr(Impulse.kr(0) + CoinGate.kr(0.1, trig), 0, Dxrand(freqs, inf));

    //Remove double-trig
    trig = Trig.kr(trig, 0.2);

    //Delay to compensate for FFT latency
    snd = DelayN.ar(snd, 0.1, 1024 / SampleRate.ir);

    //Random freq shift per onset
    snd = LinXFade2.ar(snd, -1 * FreqShiftAA.ar(snd, randFreq), EnvGen.ar(Env([-1, -1, 1], [0.02, 0.05]), trig).lag(0.02));

}).play
)

//### END TEST ###

q.player.playSegment(32)
q.player.currentEvent
q.player.stop;
(
//## Patterns #######

q.player.setPtn(Pbind(
	\hello, Pfunc { |ev|
		if (ev.part == 2) {
			var rep;
			//Make phrase more distant for every repeat
			if ((rep = ~t.repeats[ev.phrase]) > 1) {
				rep.debug("Distance");
				ev.instrument = \bufSegmentMS;
				ev.midAmp = ((rep - 1) * -6).dbamp;
				ev.sideAmp = ((rep - 1) * 1.5).dbamp;

			}
		};
		0;
	}
));

q.player.setIterator(
	Plazy({
		var part = ~data.lookup.part;
        var mk = MarkovSet(q.markov.markovSet);
		Pseq([
			//First phrase is always the same
			0,
			//Part 0 have randomized phrases
			Pseq(Array.series(part[1]-1, 1).scramble),
			//Part 1 is sequential
			Pseries(part[1], 1, part[2]-part[1]),
			//TODO: How long will this go on? How should we transition?
            Pfin((part[3] - part[2]) + 1, p {
				var x=part[2].rrand(part[3]-1);
				~t.repeats = (part[2]..part[3]).collectAs(_->0, Event);
				loop {
					~t.repeats[x] = ~t.repeats[x] + 1;
				    x.yield;
                    x = mk.next(x);
                }
            }),
			//Part 3 is random, and plays at least n-1 phrases
			Pseq((part[3] .. ~data.phrase.size - 2).scramble),
            //If last phrase is not the next-to-last in the song, go on with the very last phrase
			Pif(Pfuncn({ ~currentEvent.phrase != 46 }), q.player.data.phrase.size - 1, nil)


		]);
	})
)
)

//Sonny Schmidt
~buf4 = Buffer.read(s, "songs/04-Qin 2 __-44100.wav".resolveRelative);
(
Ndef(\sonny, {
    var snd = PlayBuf.ar(2, ~buf4, BufRateScale.kr(~buf4));
    // var sonny = DelayC.ar(snd, 10, LFNoise2.ar(1).range(0, 1));
    var fb = FbNode(2, 0);
    var fbsig = fb.delay(amp);
    var sonny = Fb({
		arg feedback; // this will contain the delayed output from the Fb unit

        LeakDC.ar(AllpassN.ar((feedback * 0.2) + snd, 0.05, 1/43, 1))

    }, 1/41);
    snd + sonny.softclip;
}).play;
)

FbNode
Quarks.gui
1/13
12.nthPrime


//## Callbacks ####
(
//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar
q.player.onReady = {
};
)

q.player.actions.part.onStart = { |ev, x| "PART %".format("ABCD"[x]).debug }


q.player.play
q.player.stop
