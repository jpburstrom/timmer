SynthDef(\resonate, { | inbus=0, outbus=0, freq=440 |
	var snd = In.ar(inbus, 2);
	snd = Resonz.ar(snd, freq, 0.001, 20);
	snd = snd * EnvGen.ar(Env.asr(\attack.kr(1), \amp.kr(1), \release.kr(1)), \gate.kr(1), doneAction:2);
	Out.ar(outbus, snd);
}).add;


