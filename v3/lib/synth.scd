Req.load(#[params, proxyspace], { |params, px, cleanup|

	var clist = List();
	//Double bass input
	var dbin = 1;
	//Double bass output
	var dbout = 2;

	cleanup.addFunc {
		clist.do(_.free);
	};

	px.push;

	~testtone = { SinOsc.ar(180) * 0.1 };

	~bass = {
		SoundIn.ar(dbin);
	};

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

	//Mod delay
	~microshift = {
		var depth, speed, range, lfo, trig;
		var lagtime = 0.1;
		depth = \depth.kr(0, 0);
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

	~output = {
		var snd = \in.ar * 12.dbamp;
		snd = Compander.ar(snd, snd, 0.1, 1, 0.33);
		snd
	};


	//-------ROUTING---------------

	//Serial routing
	#[bass, microshift, eq, output].doAdjacentPairs { |in, out|
		px[out].set(\in, px[in]);
	};

	~output.play(dbout);

	//-------MAPPINGS-------------

	//TODO: Map controls to parameters, like this
	#[depth, speed, mix].do { |param, i|
		clist.add(params.main[i].action_({ |cv|
			px[\microshift].set(param, px[\microshift].getSpec(param).map(cv.input));
		}));
	};

	params.eq24.do { |cv, i|
		clist.add(cv.action = { |v| px[\feedbass].set(\eqGain, params.eq24.collect(_.value)) });
	};



	px[\feedbass].play(dbout);

	px.pop;

	//Synth control proto
	Proto({



		~triggerFreezeSynth = { |degree|
			"TODO: trig freeze synth, degree %".format(degree).postln;

			4; //output duration of synth
		};


	});
});
