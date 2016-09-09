//# 04 #

//Exploring different ways of randomizing phrases
//See iterator for details

//For later, needs more interesting sound. Explore parallel freqshifted track, or something similar

q.player.bounce

//## Initialize ###
(
var markov;

"lib/init".import;
q.player.actionLabels = #[phrase, part];
q.player.tickLabel = \phrase;
q.player.loadData("04");
//q.player.extractFeatures;
// q.playerui.connect(q.player);

SynthDef(\bufSegmentResonance, {|out(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(0.002);
    var snd;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
    snd = RLPF.ar(PinkNoise.ar * FreqShiftAA.ar(snd, \freq.kr(440).neg), \freq.kr, 0.01);
    snd = snd.tanh * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);



    OffsetOut.ar(out, snd * \amp.kr(1));
}).add;


//This loads a previously generated markov chain
markov = "lib/protos/markov-trainer".import;
markov.setBounds(q.player.data.lookup.part[2], q.player.data.lookup.part[3] - 1);
markov.connect(q.player);
markov.initChain;

q.player.onReady = {
	//TODO: separate send bus for reverb

	//Freqshift needs a bit of hi cut, because of noise
	~t.freqshiftbus = Bus.audio(s, 2);
	~t.freqshiftEq = {
		var snd = In.ar(~t.freqshiftbus, 2);
		snd = BHiShelf.ar(snd, 4700, 2, -10);
		Out.ar(0, snd);
	}.play(~t.postGroup);

	~t.reverb = Synth(\plate_reverb_2x2, [\amp, -3.dbamp,
		\bandwidth, 5000, \decay, 0.01, \predelay, 10, \excursion, 0.9,
		\in_diff1, 0.46, \in_diff2, 0.40
	], ~t.sendGroup);
};

//Modifying pattern
q.player.setPtn(Pbind(
	//Adjust duration so next attack doesn't cause clicks
	\dur, Pkey(\dur) - 0.01,
	//if not normal, anything could happen
	\normal, Prout({ |ev|
		var norm=true, time=0;
		loop {

			//Make sure two 'normal' segments aren't playing simultaneously.
			if (norm or: { time == 0 }) {
				//Save current time plus segment duration
				norm = true; //
				time = thisThread.seconds + ev.dur;
			};

			ev = norm.yield;

			if (time < thisThread.seconds) {
				//If a normal segment isn't playing,
				//toss a coin to see if this segment should be normal
				norm = 0.1.coin;
			} {
				//If a normal segment is playing, set normal to false
				norm = false;
			};

		}
	}),
	//TODO: generalize separate keys into a chained Psym or something
	\instrument, Pif(Pkey(\normal), \bufSegment, Pwrand([\bufSegmentFreqshift, \bufSegmentPlank, \bufSegmentResonance], [0.8, 0.1, 0.1], inf)),
    \out, Pif(Pkey(\normal), 0, Pfunc { ~t.freqshiftbus }),
	\freqshift, Pwhite(-200, -2000),
	\amp, Pif(Pkey(\normal), 1, Pkey(\freqshift).explin(-2000, -200, 4, 1)),
	\fadetime, 0.02,
    \bufRate, Pif(Pkey(\normal), 1, Pwrand([0.5, 1], [0.1, 0.9].normalizeSum, inf)),
	\dur, Pif(Pfunc { |ev|
		ev.normal or: {
			ev.phrase >= 46 //46 and 47 are possible last phrases;
		}
	},
		Pkey(\dur), Pkey(\dur) * Pwhite(0.4, 1) * Pseg(Pseq([Pwhite(0.01, 0.1, 1), Pwhite(0.5, 1, 1)], inf), Pwhite(5, 20), )),
	\delta, Pif(Pkey(\normal), 0, Pkey(\dur)),
    // \pan, Pif(Pkey(\normal), 0, Pwhite(-1, 1.0)),
	\hello, Pfunc { |ev|
        if (ev.instrument == \bufSegmentResonance) {
            ev.freq = #[40,45,50,55].midicps.choose;
            ev.fadetime = 0.1;
        };

        if (ev.part == 2) {
			var rep;
			//Make phrase more distant for every repeat
			//TODO: This effect could be better/more interesting
            /*
			if ((rep = ~t.repeats[ev.phrase]) > 1) {
				rep.debug("Distance");
				//FIXME: can't just change instrument, see normal above
				ev.instrument = \bufSegmentMS;
				ev.midAmp = ((rep - 1) * -6).dbamp;
				ev.sideAmp = ((rep - 1) * 1.5).dbamp;

			}
            */
		};
		0;
	}
));

//Iterator
q.player.setIterator(
	Plazy({
		var part = ~data.lookup.part;
        var mk = MarkovSet(markov.markovSet);
		Pseq([
			//First phrase is always the same
			0,
			//Part 0 have randomized phrases
			Pn(Plazy({ Pseq(Array.series(part[1]-1, 1).scramble) }), 6),
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
);

// q.player.play
)
q.player.bounce


/*------------------------------------------------------------*/
/*EOF*/
/*------------------------------------------------------------*/

~buf4 = Buffer.read(s, "songs/04*.wav".resolveRelative.pathMatch.last);

(
Ndef(\noiseOnly, {

    var winSize = 4096;

    var amp, snd = PlayBuf.ar(2, ~buf4, BufRateScale.kr(~buf4)).sum;

    var chain = FFT(LocalBuf(winSize), snd);

    chain = PV_NoiseSynthF(chain, 1);
    // chain = PV_MagSmear(chain, MouseX.kr(1, 20));
    // chain = PV_NoiseSynthP(chain, 0.2pi);
    // chain = PV_PhaseShift(chain, 10, 1);

    // amp = Amplitude.ar(snd, winSize * SampleRate.ir, 0.1).poll;

    snd = DelayN.ar(snd, 0.2, winSize * SampleRate.ir);


    // snd = IFFT(chain);
    // snd = LinXFade2.ar(snd, IFFT(chain), K2A.ar(MouseY.kr(-1, 1.0)));
    snd = IFFT(chain);

    // snd = HPF.ar(snd, 440);

    snd.dup

}).mold.play
)


(
Ndef(\noiseOnly2, {

    var winSize = 4096;

    var amp, snd = PlayBuf.ar(2, ~buf4, BufRateScale.kr(~buf4), startPos:10*44100).sum;

    var fq = LFNoise2.kr(1).exprange(50, 2000);
    var chain1 = FFT(LocalBuf(winSize), FreqShiftAA.ar(snd, -4000));
    var chain2 = FFT(LocalBuf(winSize), snd);

    chain1 = PV_MagMul(chain2, chain1);

    IFFT(chain1).dup;


    RLPF.ar(PinkNoise.ar * FreqShiftAA.ar(snd, fq.neg).dup, fq, 0.01);

    // snd

}).mold.play
)

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

