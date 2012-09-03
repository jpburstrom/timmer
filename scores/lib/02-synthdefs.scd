//Timmer.grain1 - basic stereo single-grain player.
( 
	var grainFactory = { |label, def| 
		SynthDef(label, { |out, aux1, aux2, aux3, aux4|
				var sound = SynthDef.wrap(def);
				OffsetOut.ar(out, sound);
				OffsetOut.ar(aux1, sound);
				OffsetOut.ar(aux2, sound);
				OffsetOut.ar(aux3, sound);
				OffsetOut.ar(aux4, sound);
		}).store;
	};

	var fxFactory = { |label, def| 
		SynthDef(label, { |out, aux1, aux2, aux3, aux4|
				var sound = SynthDef.wrap(def);
				Out.ar(out, sound);
				Out.ar(aux1, sound);
				Out.ar(aux2, sound);
				Out.ar(aux3, sound);
				Out.ar(aux4, sound);
		}).store;
	};

	grainFactory.('timmer.grain1', 
	{ 
			arg start, time, bufnum, rate = 1, pan = 0, amp = 1, attack = 0.001, decay = 0.02;
			var env, l, r;
			start = start - (attack * SampleRate.ir);	
			#l, r = PlayBuf.ar(2, bufnum, rate * BufRateScale.kr(bufnum), 1, start, 0)
				* EnvGen.kr(Env.linen(attack, time, decay), doneAction: 2);
			Balance2.ar(l, r, pan, amp)
	});

	grainFactory.('timmer.hit', 
	{ 
		arg bufnum, rate = 1, pan = 0, amp = 1, attack = 0.001, decay = 0.02;
		var time, env, l, r;
		time = BufDur.kr(bufnum) - attack - decay;
		#l, r = PlayBuf.ar(2, bufnum, rate * BufRateScale.kr(bufnum), 1, 0, 0)
			* EnvGen.kr(Env.linen(attack, time , decay), doneAction: 2);
		Balance2.ar(l, r, pan, amp)
	});

	grainFactory.('timmer.grain3', 
	{ 
		arg startPos, dur, bufnum, bufRate = 1, pan = 0, amp = 1, 
				attack = 0.1, decay = 0.02;
		var env, l, r;
		startPos = (startPos) * BufFrames.kr(bufnum);	
		#l, r = PlayBuf.ar(2, bufnum, 
			bufRate * BufRateScale.kr(bufnum) * EnvGen.kr(Env.perc(0.01, 20, curve:8)),
			1, startPos, 0) * EnvGen.kr(Env.perc(attack, dur), doneAction: 2);
		Balance2.ar(l, r, pan, amp)
	});

//EFFECTS
	fxFactory.('bitCrushDelay', 
	{ | in, length=0.2, feedback=0.36, lop=816, hip=100, mix=1, resolution=6 |
		var source, local;
		feedback = feedback.min(0.9999999);
		source = In.ar(in, 2);//(Decay.ar(Impulse.ar(0.3), 0.1) * WhiteNoise.ar(0.2)).dup;
		local = HPF.ar(
			LPF.ar((LocalIn.ar(2) + source).round(2.pow(resolution).reciprocal)				, lop), hip);
			local = DelayC.ar(local, 2, length);
			LocalOut.ar(local * feedback);
		  XFade2.ar(source, local, mix);
  });

	fxFactory.('stereoConvReverb', 
	{ |bufL=0, bufR=1, in=0, gate=1, mix=1, amp=1|
		var left, right;
		#left, right = In.ar(in, 2);
    XFade2.ar([left, right], 
			[ PartConv.ar(left, 2048, bufL, 1), PartConv.ar(right, 2048, bufR, 1) ],
			mix, amp);
  });

)
