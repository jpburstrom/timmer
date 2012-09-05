f = SoundFile.collectIntoBuffers("/Volumes/HD2/projects/timmer/samples/banks/hits/*")
f = SoundFile.collectIntoBuffers("/Volumes/HD2/projects/timmer/samples/banks/part4-huff/*")
f.do(_.normalize)

(
SynthDef("\impulseTest2", { arg bufnum=0, freq=440, grainlen=2, attack=0.01, sustain=1, release=0.01,out=0, softness=100;
	  var num, trig, snd, voices=4, start, env, startctl, scale, l, r;
		trig = Impulse.ar(freq);
    num = Stepper.ar(trig, 0, 0, voices-1);
		grainlen = grainlen.min(35);

		start = SinOsc.ar(\pwm.kr, Rand(), 2000, 2400);

		scale = BufRateScale.kr(f[0]);

		snd = Mix.fill(voices, { |i|
				var thisTrig = BinaryOpUGen('==', num, i);
				PlayBuf.ar(2, bufnum, scale, thisTrig, start) 
						* Lag.ar(Trig.ar(thisTrig, freq.reciprocal * grainlen), softness * 0.0001)
			});
		#l, r = snd * EnvGen.ar(Env.linen(attack, sustain-attack, release, curve:\cubed), doneAction:2);
		Out.ar(out, Balance2.ar(l, r, \pan.kr, \amp.kr));
	}
).add

)

}
(
~ptn = Pbind(
		\instrument, \impulseTest2,
		//\dur, Penv([1, 0.001], [30], \exp),
		//\note, Pkey(\hellonote),//Array.rand(4, -12, 2), //Prand([Prand([-12, 10]),7], inf),
		//\note, 0,
		\root, -6,
		\dur, Pbrown(0.2,0.22),
		/q\strum, 0.05,
		\grainlen, 2,
		\legato, 0.01,
		\release, Pkey(\dur) * 8,
		\attack, 0,
		\amp, 0.3,
		\out, 2,
		\softness, 10, //Pwhite(0,30),//Pwhite(0.1, 0.6)
		\pwm, Plprand(0.05, 0.1),
		\change, Pwhite(8,24),
		\bufnum, Pstutter(Pkey(\change), Pfuncn({f.choose}, inf)),
		\pan, Pstutter(Pkey(\change), Pwhite(-0.5, 0.5)),
		//\env, Env(Array.rand(8, 400, 4000), Array.rand(7, 10,20), \sin)
		//\start, Pn(Penv(Array.rand(20, 0, 1.0), Array.rand(19, 1, 7.0), \sin)) * 4000 + 400
	);
Pdef( \impulses2,
	//Pbindf(~ptn, \note, Pstutter(Pkey(\change), Pxrand([[-29], [-24], [-48]], inf)))
	//Pbindf(~ptn, \degree, Pstutter(Pkey(\change), Pfuncn({Array.rand(3, 0, 8)}, inf)))
	//Pbindf(~ptn, \degree, Pseq([-30,-29,-28,-27,-25,-23,-21,-19], inf))
	Pbindf(~ptn, \degree, Pstutter(Pkey(\change), Pfuncn({Array.rand(3, 0, 8)}, inf)))
).play
)

