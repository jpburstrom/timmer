Req.load(#[params, proxyspace], { |params, proxyobj, cleanup|
	var clist = List();
	//Double bass input
	var dbin = 1;
	//Double bass output
	var dbout = 2;

	var px = proxyobj.proxyspace;

	var data = (
		//Minor + major pentatonic, from
		//Octave above open strings
		//0-3: E-G major pentatonic
		//4-7: E-G minor pentatonic
		scales: 	[\E2, \A2, \D3, \G3].collect({ |x| [x.namemidi + [0,2,4,7,9], x.namemidi + [0,3,5,7,10]]}).flop.flat.clump(5);
	);


	//Calculate modulation output from a specific parameter
	//where modnp is a nodeproxy with 2 .kr outputs, and param is any parameter to be modulated
	var calcModMap = { |modnp, param|
		var mod, modMax;
		#mod, modMax = modnp.kr(2);
		//Make sure modulation is in a sensible range
		param * (mod + (1 - modMax));

	};

    //for testing
    if (s.options.device == "Boris") {
        dbin = 0;
        dbout = 0;
    };

	cleanup.addFunc {
		clist.do(_.free);
	};

	px.push;

	~testtone = { SinOsc.ar(180) * 0.1 };

	~bass = {
		SoundIn.ar(dbin);
	};

	//~bass.parentGroup = proxyobj.input;


	~ampRaw = {
		Amplitude.kr(~bass.ar, 0.01, 1);
	};

	~ampCooked = {
		var snd = \in.kr(0);
		//6 is the magic number
		(snd * 3).min(1);

	};
	~ampCooked.set(\in, ~ampRaw);

	~simpleGate = {
		(\in.kr(0) > 0.005);
	};
	~simpleGate.set(\in, ~ampRaw);

	~ampLong = {
		var amp, ampLong, ampLongWindow=1;
		amp = \in.kr(0);
		ampLongWindow = ControlRate.ir * ampLongWindow;
		ampLong = RunningSum.kr(amp, ampLongWindow) / ampLongWindow;
		ampLong = ~ampRaw.kr * ((((amp - ampLong).abs) * \longAmpScale.kr(5)).min(1).max(0)); //Roughly scale the value from 0-1
		// ampLong.scope;
		SendReply.kr(Impulse.kr(30), '/amp', [amp, ampLong]);
		ampLong
	};
	~ampLong.set(\in, ~ampRaw);


	~onsets = { arg threshold=0.1, relaxtime=2, floor=0.5;
		var onsets, chain = FFT(LocalBuf(512), ~bass.ar);
		onsets = Onsets.kr(chain, threshold, \wphase, relaxtime: relaxtime, floor:floor);
		onsets * ~simpleGate.kr;
	};

	~pitch = {
		var snd, freq, hasFreq;
		snd = LPF.ar(~bass.ar(1));
		Tartini.kr(snd);

	};
	~silenceDetect = {
		~simpleGate.kr.lagud(0.05, 1) < 1;
	};

	s.bind {
	//Modulations
	//Sending array with value + maxvalue
	~modMLFODepth = {
		[(\amp.kr * \mod.kr(0).lagud(\lag.kr(1), 0.1)) * 0.1, \amp.kr * 0.1];

	};


	~modTLFODepth = {
		[(\amp.kr * \mod.kr(0).lagud(\lag.kr(1), 0.1)), \amp.kr];
	};

	//Detune freeze + resonance
	~modDetune = {
		[\amp.kr - (\amp.kr * \mod.kr(0).lagud(0.1, \lag.kr(1))), \amp.kr];
	};

	~modReverbMix = {
		//Low amp = more reverb
		//Multiply with dry/wet
		[\amp.kr - (\amp.kr * \mod.kr(0).lagud(0.1, \lag.kr(1))), \amp.kr];
	};

	~modMLFODepth.set(\mod, ~ampCooked);
	~modTLFODepth.set(\mod, ~ampCooked);
	~modDetune.set(\mod, ~ampCooked);
	~modReverbMix.set(\mod, ~ampCooked);

	};

	//Mod delay
	~microshift = {
		var depth, speed, range, lfo, trig;
		var lagtime = 0.1;
		depth = calcModMap.(~modMLFODepth, \depth.kr(0));
		speed = \speed.kr(0, 0);
		range = (depth/ (speed * 2)).min(1);
		speed = speed.lag(lagtime);
		depth = depth.lag(lagtime);
		// trig = Latch.kr(Changed.kr(range),
		lfo = LinXFade2.ar(SinOsc.ar(speed), LFDNoise3.ar(speed), K2A.ar(\mix.kr(0)));
		//If value is changed, move to max for a while
		//lfo = LinXFade2.ar(K2A.ar((depth * 2) - 1), lfo, K2A.ar((Trig.kr(Changed.kr(range), lagtime) * -2) + 1).lag(lagtime));
		lfo = lfo.clip2.range(0, range.lag(lagtime));
		DelayC.ar(\in.ar, 2, lfo);
	};

	~microshift.addSpec(
		\depth, [0.0, 1.0, 8],
		\speed, [1.0, 20, \exp, 0, 0.1, "hz"],
		\mix, [-1, 1, \lin]
	);

	~eq = {
		var snd, ctl, freqs;
		freqs = params.eqFreqs;
		snd = \in.ar;
		ctl = NamedControl.kr(\eqGain, 0 ! freqs.size);

		//Highpass filter
		4.do { snd = HPF.ar(snd, 60) };

		//n-band EQ
		freqs.do { |freq, i|
			//see http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/What-is-rq-really-td5619928.html
			//0.03125 = 1 / 16 (0.5 semitones between -3 db)
			snd = BPeakEQ.ar(snd, freq, 0.0625, \eqGain.kr[i]);
		};

		//Steep highshelf to cut high frequencies
		snd = BHiShelf.ar(snd, 300, 1, -32);

	};

	~tremolo = {
		var depth, speed, lfo;
		var mod, modMax;
		depth = calcModMap.(~modTLFODepth, \depth.kr(0));
		speed = \speed.kr(0, 0.1);
		lfo = LinXFade2.ar(SinOsc.ar(speed), LFDNoise3.ar(speed), K2A.ar(\mix.kr(0)));
		lfo = ((1 - depth) + (depth * lfo * 128)).clip(-1,1); //offset
		\in.ar * lfo;
	};

	~tremolo.addSpec(
		\depth, [0.0, 1.0],
		\speed, [1.0, 20, \exp, 0, 0.1, "hz"],
		\mix, [-1, 1, \lin]
	);




	// ~decimator = {
	// 	var snd = \in.ar(1);
	// 	var bits = \amount.kr.linlin(0, 1, 24, 12);
	// 	snd = XFade2.ar(snd, Decimator.ar(snd * ~simpleGate.kr, 48000, 4) * 0.1, K2A.ar(\amount.kr).linlin(0, 1, -1, 1));
	// };
	//
	// ~decimator.addSpec(\amount, [0, 1, \lin]);

	//RESONANCE
	~resonance = {
		var out, snd = \in.ar;
        var freqs, amps, decay, pitch;
        freqs = \notes.kr(data.scales[2]);
        freqs = (freqs + {~modDetune.kr(2)[0] * LFNoise2.kr(1) * 2}.dup(freqs.size) ).midicps;
        amps = freqs.size.collect(0.2.rrand(0.8));
		decay = freqs.size.collect(5);
		pitch = 1;//Latch.kr(~pitch.kr(2)[0] / base, ~onsets.kr(1)).max(0.25).min(2);

		//TODO: correct mapping amp -> lFnoise
		//TODO: scales from freezeScale
		pitch = 1; //* 2.pow(LFNoise2.kr(10, LFNoise2.kr(1).range(0, (0.2 - ~ampRaw.kr(1).lagud(0, 5)).max(0))));
		// var pitch = Demand.kr(~onsets.kr(1), 0, Drand((0..12).midiratio, inf));
		//snd = snd + Ringz.ar((snd * PinkNoise.ar) * EnvGen.ar(Env.perc, ~onsets.kr(1)), 1200, 1, 0.1);
		out = DynKlank.ar(`[freqs, amps, decay], DelayC.ar(snd * \amp.kr(0), 0.02, 0.02) * EnvGen.ar(Env.perc(0, 0.2), ~onsets.kr(1)), pitch) * -36.dbamp;
		// out = Compander.ar(out, out, 0.05, 1, 0.33);
		snd + out;
	};


	//REVERB
	s.bind {
		~reverb = { |revTime = 3, animRate = 0.1, animDepth = 0.03,
			hfDamping = 0.1, predelay = 0.02,
			inFilter = 0.6, leakCoeff = 0.995,
			combScale = 1, apScale = 1|

			var src, verb;
			var mod, modMax;

			src = \in.ar;

			verb = AdCVerb2.ar(src * 0.1,
				revTime: revTime.lag(0.5),
				hfDamping: hfDamping.lag(0.5),
				nOuts: 2,         // fixed number of decorrelated output channels
				predelay: predelay.lag(0.5),
				numCombs:     8,     // fixed number - increase for more density
				numAllpasses: 4,     // fixed number - increase for more diffuseness
				inFilter: inFilter,
				leakCoeff: leakCoeff,
				combScale: combScale.lag(0.5), // lagged to
				apScale: apScale.lag(0.5)
			);

                XFade2.ar(src, verb, calcModMap.(~modReverbMix, \mix.kr(0)).linlin(0,1,-1,1));
		};
		~reverb.set('animDepth', 1.0, 'animRate', 0.3981071705535, 'combScale', 1.3639149005216, 'predelay', 0.0, 'hfDamping', 0.76666666666667, 'revTime', 6.6408278506348, 'inFilter', 0.55);
	};
	~reverb.addSpec(\mix, \amp.asSpec);




	//OUTPUT
	~output = {
		var snd = \in.ar * 12.dbamp;
		snd = Compander.ar(snd, snd, 0.1, 1, 0.33);
		snd
	};

	//-------ROUTING---------------

	//Serial routing
	#[
		bass,
		microshift,
		eq,
		tremolo,
		resonance,
		reverb,
		output].doAdjacentPairs { |in, out|
		//px[out].parentGroup_(proxyobj.synths);
		px[out].set(\in, px[in]);
	};


	~output.play(dbout);

	//-------MAPPINGS-------------

	//Map controls to parameters, like this
	//Pairs of nodeproxy, param
	//map to index of params.main

    //TODO: make this list global somehow
	#[
		microshift, depth,
		microshift, speed,
		microshift, mix,
		tremolo, depth,
		tremolo, speed,
		tremolo, mix,
		resonance, amp,
		reverb, mix
		//decimator, amount
	]
	.pairsDo { |np, param, i|
		i = i/2; //pairsDo outputs 0,2,4...
		clist.add(params.main[i].action_({ |cv|
			px[np].set(param, px[np].getSpec(param).map(cv.input));

		}));
		//TODO: set values from params.main? changed(\synch)?
	};

	//EQ
	params.eq24.do { |cv, i|
		clist.add(cv.action = { |v| px[\eq].set(\eqGain, params.eq24.collect(_.value)) });
		px[\eq].set(\eqGain, params.eq24.collect(_.value));

	};

    clist.add(params.meta.freezeScale.action = { |cv|
        px[\resonance].set(\notes, data.scales[cv.value]);
    });

	//Amplitude -> different things
	#[modMLFODepth, modTLFODepth, modDetune, modReverbMix].do { |k, i|
		clist.add(params.meta.featureMap[i].action = { |cv| px[k].set(\amp, cv.value) });
	};

	//Synth control proto
	Proto({



		~triggerFreezeSynth = { |degree|
			"TODO: trig freeze synth, degree %".format(degree).postln;

			4; //output duration of synth
		};


	});
});
