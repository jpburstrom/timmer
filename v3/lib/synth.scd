Req.load(#[params, proxyspace], { |params, px, cleanup|

	var clist = List();
	var dbout = 2;

	cleanup.addFunc {
		clist.do(_.free);
	};

	px[\feedbass][0] = {
		var snd, presnd;
		var freqs = params.eqFreqs;
		var ctl = NamedControl.kr(\eqGain, 0 ! freqs.size);
		var amp;
		//--- EQ ---//
		//Steep highpass
		snd = SoundIn.ar(1);
		amp = Amplitude.ar(snd, 0.1, 0.1).lag(0.5);
		4.do { snd = HPF.ar(snd, 60) };
		freqs.do { |freq, i|
			//see http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/What-is-rq-really-td5619928.html
			//0.03125 = 1 / 16 (0.5 semitones between -3 db)
			snd = BPeakEQ.ar(snd, freq, 0.0625, \eqGain.kr[i]);
		};

		//Out.ar(~freezeBus, snd);
		snd = BHiShelf.ar(snd, 300, 1, -32);

		//Out.kr(~pitchBus, Pitch.kr(snd));

		//snd = snd * EnvGen.ar(Env.linen(1, 1, 0.02), Dust.kr(1), timeScale: LFNoise2.kr(1).range(0.05, 1));

		snd = snd * 12.dbamp;

		snd = Compander.ar(snd, snd, 0.1, 1, 0.33);
		snd
	};

	//Mod delay
	px[\microshift] = { arg snd, depth, speed, mix;
		var lfo = LinXFade2.ar(SinOsc.ar(speed), LFDNoise3.ar(speed), mix);
		snd = DelayC.ar(snd, 2, lfo.poll);
	};

	px[\microshift].addSpec(
		\depth, [0.0, 12.0, \lin],
		\speed, [0.1, 20, \exp, 0, 0.1, "hz"],
		\mix, [0.0, 1, \lin]
	);


	//TODO: Map controls to parameters, like this
	clist.add(q.params.main[0].action_({ |cv|
		px[\microshift].set(\depth, px[\microshift].getSpec(\depth).map(cv.input));
	}));

	q.params.eq24.do { |cv, i|
		clist.add(cv.action = { |v| px[\feedbass].set(\eqGain, q.params.eq24.collect(_.value)) });
	};



	px[\feedbass].play(dbout);

	//Synth control proto
	Proto({



		~triggerFreezeSynth = { |degree|
			"TODO: trig freeze synth, degree %".format(degree).postln;

			4; //output duration of synth
		};


	});

	q.px = px;
});
