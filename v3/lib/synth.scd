Req.load(#[params, proxyspace], { |params, proxyobj, cleanup|

	var clist = List();
	//Double bass input
	var dbin = 1;
	//Double bass output
	var dbout = 2;

	var px = proxyobj.proxyspace;

	proxyobj.postln;

	cleanup.addFunc {
		clist.do(_.free);
	};

	px.push;

	~testtone = { SinOsc.ar(180) * 0.1 };

	~bass = {
		SoundIn.ar(dbin);
	};

	//~bass.parentGroup = proxyobj.input;


	~amp = {
		Amplitude.kr(~bass.ar, 0.01, 1);
	};

	~simpleGate = {
		(~amp.kr > 0.005);
	};

	~ampTilt = {
		var amp, ampLong, ampLongWindow=1;
		amp = ~amp.kr(1);
		ampLongWindow = ControlRate.ir * ampLongWindow;
		ampLong = RunningSum.kr(amp, ampLongWindow) / ampLongWindow;
		ampLong = ~amp.kr * ((((amp - ampLong).abs) * \longAmpScale.kr(2.5)).min(1).max(0)); //Roughly scale the value from 0-1
		// ampLong.scope;
		ampLong
	};

	~ampTilt.gui;

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

	// ~decimator = {
	// 	var snd = \in.ar(1);
	// 	var bits = \amount.kr.linlin(0, 1, 24, 12);
	// 	snd = XFade2.ar(snd, Decimator.ar(snd * ~simpleGate.kr, 48000, 4) * 0.1, K2A.ar(\amount.kr).linlin(0, 1, -1, 1));
	// };
	//
	// ~decimator.addSpec(\amount, [0, 1, \lin]);

	~resonance = {
		var out, snd = \in.ar;
		var base = "D1".namecps;
		var freqs = ("D3".namemidi + [0,2,4,7,9]).midicps; //stretch
		var amps = freqs.size.collect(0.2.rrand(0.8));
		var decay = freqs.size.collect(5);
		var pitch = Latch.kr(~pitch.kr(2)[0] / base, ~onsets.kr(1)).max(0.25).min(2);
		//TODO: correct mapping amp -> lFnoise
		//TODO: scales from freezeScale
		pitch = 1 * 2.pow(LFNoise2.kr(10, LFNoise2.kr(1).range(0, (0.2 - ~amp.kr(1).lagud(0, 5)).max(0))));
		// var pitch = Demand.kr(~onsets.kr(1), 0, Drand((0..12).midiratio, inf));
		//snd = snd + Ringz.ar((snd * PinkNoise.ar) * EnvGen.ar(Env.perc, ~onsets.kr(1)), 1200, 1, 0.1);
		out = DynKlank.ar(`[freqs, amps, decay], DelayC.ar(snd * \amp.kr(0), 0.02, 0.02) * EnvGen.ar(Env.perc(0, 0.2), ~onsets.kr(1)), pitch) * -36.dbamp;
		// out = Compander.ar(out, out, 0.05, 1, 0.33);
		snd + out;
	};


	~output = {
		var snd = \in.ar * 12.dbamp;
		snd = Compander.ar(snd, snd, 0.1, 1, 0.33);
		snd
	};

	//-------ROUTING---------------

	//Serial routing
	#[bass, microshift, eq, resonance, output].doAdjacentPairs { |in, out|
		//px[out].parentGroup_(proxyobj.synths);
		px[out].set(\in, px[in]);
	};

	~output.play(dbout);

	//-------MAPPINGS-------------

	//Map controls to parameters, like this
	//Pairs of nodeproxy, param
	//map to index of params.main

	//TODO: set to current CV values
	#[
		microshift, depth,
		microshift, speed,
		microshift, mix,
		resonance, amp,
		decimator, amount
	]
	.pairsDo { |np, param, i|
		i = i/2; //pairsDo outputs 0,2,4...
		clist.add(params.main[i].action_({ |cv|
			px[np].set(param, px[np].getSpec(param).map(cv.input));
		}));
	};


	params.eq24.do { |cv, i|
		clist.add(cv.action = { |v| px[\eq].set(\eqGain, params.eq24.collect(_.value)) });
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
