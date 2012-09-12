//Timmer.grain1 - basic stereo single-grain player.
~p.fact = Proto({ 
	~grain =  { |label, def| 
		//Default freq: C3
		SynthDef(label, { arg out, aux1, aux2, aux3, aux4, freq=261.6255653006, 
				pan=0, amp=1, attack=0.001, bufnum=0;
				var sound = SynthDef.wrap(def, prependArgs: [freq, pan, amp, attack, bufnum]);
				OffsetOut.ar(out, sound);
				OffsetOut.ar(aux1, sound);
				OffsetOut.ar(aux2, sound);
				OffsetOut.ar(aux3, sound);
				OffsetOut.ar(aux4, sound);
		}).add;
	};

  ~synth = { |label, def| 
		SynthDef(label, { |out, aux1, aux2, aux3, aux4|
				var sound = SynthDef.wrap(def);
				Out.ar(out, sound);
				Out.ar(aux1, sound);
				Out.ar(aux2, sound);
				Out.ar(aux3, sound);
				Out.ar(aux4, sound);
		}).add;
	};
});

(
	~p.fact.grain('timmer.grainLinen', 
	{ 
			arg freq, pan, amp, attack, bufnum, decay=0.001, startPos, sustain=0.2;
			var env, l, r, rate=freq/60.midicps;
			startPos = (startPos * BufFrames.kr(bufnum)) - (attack * SampleRate.ir);	
		  sustain = sustain - attack - decay;
			#l, r = PlayBuf.ar(2, bufnum, rate * BufRateScale.kr(bufnum), 1, startPos, 0)
				* EnvGen.ar(Env.linen(attack, sustain, decay, curve:\curve.kr), doneAction: 2);
			Balance2.ar(l, r, pan, amp)
	});


	~p.fact.grain('timmer.grainPerc', 
	{ 
		arg freq, pan, amp, attack, bufnum, startPos, sustain=0.2;
		var env, l, r, rate=freq/60.midicps;
		startPos = (startPos * BufFrames.kr(bufnum)) - (attack * SampleRate.ir);	
		attack = attack.min(sustain * 0.5);
		sustain = (sustain - attack);
		#l, r = PlayBuf.ar(2, bufnum, 
			rate * BufRateScale.kr(bufnum),
			1, startPos, 1) * EnvGen.ar(Env.perc(attack, sustain, curve:\curve.kr), doneAction: 2);
		Balance2.ar(l, r, pan, amp)
	});

	~p.fact.grain('timmer.hitLinen', 
	{ 
		arg freq, pan, amp, attack, bufnum, decay=0.001;
		var sustain, env, l, r, rate=freq/60.midicps;
		sustain = BufDur.kr(bufnum) - attack - decay;
		#l, r = PlayBuf.ar(2, bufnum, rate * BufRateScale.kr(bufnum), 1, 0, 0)
			* EnvGen.ar(Env.linen(attack, sustain , decay, curve:\curve.kr), doneAction: 2);
		Balance2.ar(l, r, pan, amp)
	});

	~p.fact.grain('timmer.hitPerc', 
	{ 
		arg freq, pan, amp, attack, bufnum;
		var dur, env, l, r, rate=freq/60.midicps;
		dur = BufDur.kr(bufnum);
		attack = attack.min(dur * 0.5);
		dur = dur - attack;
		#l, r = PlayBuf.ar(2, bufnum, rate * BufRateScale.kr(bufnum), 1, 0, 0)
			* EnvGen.ar(Env.perc(attack, dur, curve:\curve.kr), doneAction: 2);
		Balance2.ar(l, r, pan, amp)
	});


	~p.fact.grain('timmer.grainMono', 
	{ 
		arg freq, pan, amp, attack, bufnum, decay=0.001, sustain, startPos;
		var env, sound, rate=freq/60.midicps;
		startPos = (startPos) * BufFrames.kr(bufnum);	
		sound = PlayBuf.ar(1, bufnum, 
			rate * BufRateScale.kr(bufnum) * EnvGen.kr(Env.perc(0.01, 20, curve:8)),
			1, startPos, 0) * EnvGen.ar(Env.perc(attack, sustain), doneAction: 2);
		Pan2.ar(sound, pan, amp)
	});


//EFFECTS
	~p.fact.synth('bitCrushDelay', 
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

	/*
	~p.fact.synth('stereoConvReverb', 
	{ |bufL=0, bufR=1, in=0, gate=1, mix=1, amp=1|
		var left, right;
		#left, right = In.ar(in, 2);
    XFade2.ar([left, right], 
			[ PartConv.ar(left, 2048, bufL, 1), PartConv.ar(right, 2048, bufR, 1) ],
			mix, amp);
  });
	*/

	~p.fact.synth('bitCrushDelay', 
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

	~p.fact.synth('timmer.sinSynth1', { |freq, amp, gate=1|
		var son, inamp;
		son = SoundIn.ar([0,1]);
		inamp = Amplitude.ar(son, 0.1, 0.1);
		SinOsc.ar(freq, mul: amp) * EnvGen.kr(Env.asr(0.01, 1, 0.01), gate, doneAction:2) * inamp;
	});
);

//This one is a bit broken, but could be useful for something
(
	~p.fact.synth('timmer.impulseSin', 
		{ arg bufnum=0, freq=440, grainlen=2, attack=0.01, sustain=1, release=0.01, softness=100,
			start=2000, length=600, bufRate=1;
	  var num, trig, snd, voices=8, env, startctl, scale, frames, l, r;
		trig = Impulse.ar(freq);
    num = Stepper.ar(trig, 0, 0, voices-1);
		grainlen = grainlen.min(4);
		scale = BufRateScale.kr(bufnum) * bufRate;
		frames = BufSampleRate.kr(bufnum);
		snd = Mix.fill(voices, { |i|
				var thisTrig = BinaryOpUGen('==', num, i);
				PlayBuf.ar(2, bufnum, scale, thisTrig, 
					SinOsc.ar(0.01, Rand(), length*frames, (start+length)*frames), 1)
						* Lag.ar(Trig.ar(thisTrig, freq.reciprocal * grainlen), softness * 0.0001)
			});
		#l, r = snd * EnvGen.ar(Env.linen(attack, sustain-attack, release, curve:\cubed), doneAction:2);
		LeakDC.ar(Balance2.ar(l, r, \pan.kr, \amp.kr));
		}
	)
);

//Here we let impulses read through a part of a soundfile, creating some kind of PWM effect
(
	~p.fact.synth('timmer.impulseSin2', 
		{ arg bufnum=0, freq=440, grainlen=2, attack=0.01, sustain=1, release=0.01, softness=100,
			start=2000, length=600, bufRate=1;
	  var num, trig, snd, voices=8, env, startctl, scale, frames, l, r, pwm;
		trig = Impulse.ar(freq);
    num = Stepper.ar(trig, 0, 0, voices-1);
		grainlen = grainlen.min(4);
		scale = BufRateScale.kr(bufnum) * bufRate;
		frames = BufSampleRate.kr(bufnum);
		pwm = SinOsc.ar(0.01, 0, (length*frames*0.5), (start+(length*0.5))*frames, trig);
		snd = Mix.fill(voices, { |i|
				var thisTrig = BinaryOpUGen('==', num, i);
				PlayBuf.ar(2, bufnum, scale, thisTrig, pwm, 1)
						* Lag.ar(Trig.ar(thisTrig, freq.reciprocal * grainlen), softness * 0.0001)
			});
		#l, r = snd * EnvGen.ar(Env.linen(attack, sustain-attack, release, curve:\cubed), doneAction:2);
		LeakDC.ar(Balance2.ar(l, r, \pan.kr, \amp.kr));
		}
	)
);
//This seem to work best, but I don't know why.
(
 ~p.fact.synth('timmer.impulseReal', { arg bufnum=0, freq=440, grainlen=2, attack=0.01, sustain=1, release=0.01, softness=100;
	  var num, trig, snd, voices=4, start, env, startctl, scale, l, r;
		trig = Impulse.ar(freq);
    num = Stepper.ar(trig, 0, 0, voices-1);
		grainlen = grainlen.min(35);

		start = SinOsc.ar(\pwm.kr, Rand(), 2000, 2400);

		scale = BufRateScale.kr(bufnum);

		snd = Mix.fill(voices, { |i|
				var thisTrig = BinaryOpUGen('==', num, i);
				PlayBuf.ar(2, bufnum, scale, thisTrig, start) 
						* Lag.ar(Trig.ar(thisTrig, freq.reciprocal * grainlen), softness * 0.0001)
			});
		#l, r = snd * EnvGen.ar(Env.linen(attack, sustain-attack, release, curve:\cubed), doneAction:2);
		LeakDC.ar(Balance2.ar(l, r, \pan.kr, \amp.kr));
	})
);
