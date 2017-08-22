SynthDef(\resonator_01, { |inbus, outbus|
		var d1 = 73.416191979352;
		var a1 = 55;
		//5 first notes in song
		var freqs = [d1 * 5, a1 * 6, 235, d1 * 3, d1 * 2];
		var snd = In.ar(inbus, 2);
		var detune = 0.2;
		var lo = detune.neg.midiratio ;
		var hi = detune.midiratio ;
        var amp = 0.5;
		//Some detuning
		//TODO: variation of LFNoise2 rate?
		//TODO: individual amps?
		snd = Mix(freqs.collect({ |fq| Resonz.ar(snd, fq * LFNoise2.kr(0.1).range(lo, hi), 0.002, amp)}));
		// snd.postln;
		Out.ar(outbus, snd);
}).add;