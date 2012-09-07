(
SynthDef("help-binScramble", { arg out=0, soundBufnum=2; Ê 
	var in, chain, onsetChain;
	in = SoundIn.ar(1);
	onsetChain = FFT(LocalBuf(512), in);
	chain = FFT(LocalBuf(16384), in, 0.25);
	chain = PV_BinScramble(chain, 1 , 0.0005, Dust.kr(5));
	chain = PV_LocalMax(chain, 0);
	chain = PV_MagSmear(chain, 3);
	//chain = PV_MagShift(chain, 1, -4096);
	//chain = PV_MagSquared(chain);
	//chain = PV_MagClip(chain, 0.5);
	chain = PV_BrickWall(chain, 0.1);
	
	Out.ar(out, (3 * IFFT(chain)).tanh.dup);
	//Out.ar(out, in.dup);
}).play(s, [\soundBufnum, b]);
)

s.meter
s.scope
PV_MagShift
PV_LocalMax

EnvGen
Env

PV_MagNoise

PV_MagSmear

(


SynthDef(\sonnyPlay, { |bus, bufnum=0, gate=1, rate=0.95, amp=1, attack=0.1, release=1.0, out=0|
			var phaseP, sound, in, chain, onsetChain, freq, hasFreq, outs;
			phaseP = Phasor.ar(Impulse.kr(0), BufRateScale.kr(bufnum)*rate, 0, BufFrames.kr(bufnum), In.ar(bus) - 100);
			sound = BufRd.ar(1, bufnum, phaseP, 1) * EnvGen.kr(Env.asr(attack, amp, release), gate, doneAction:2);
			in = sound;
				//onsetChain = FFT(LocalBuf(512), in);
	/*
	chain = FFT(LocalBuf(16384), in, 0.25);
	//chain = PV_BinScramble(chain, 1 , 0.0005, Dust.kr(5));
	//chain = PV_LocalMax(chain, 0);
	chain = PV_MagSmear(chain, 3);
	chain = PV_MagShift(chain, 2);
	chain = PV_PhaseShift(chain, LFNoise2.kr(1, 180, 180));
	//chain = PV_MagSquared(chain);
	//chain = PV_MagClip(chain, 0.5);
	chain = PV_BrickWall(chain, -0.8);
	*/
	amp = Amplitude.kr(in, 0.05, 0.05);
Ê Ê # freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);
Ê Ê //freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
Ê Ê outs = Mix.new(VarSaw.ar(freq * 2, 0, 0.5, amp));
	
	//Out.ar(out, (3 * IFFT(chain)).tanh.dup);
	Out.ar(out, outs);

}).add;


)