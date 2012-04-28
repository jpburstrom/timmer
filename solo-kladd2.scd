b = Buffer.cueSoundFile(s,"/Volumes/HD2/projects/timmer/creations/solo-kladdtest/01-120428_1727.wav" , 0, 1);
c = Buffer.cueSoundFile(s,"/Users/johannes/samples/field/zoom/032-torpet-natur-tyst-walking/001-birds-summer-insects-happy-environment-insect_flying_by.wav" , 0, 2);
(
SynthDef(\soloKladd, { |bus, bufnum=0, gate=1, rate=0.95, amp=1, attack=0.1, release=1.0, out=0|
	var phaseP, sound, in, chain, onsetChain, freq, hasFreq, outs, trig;
	in = DiskIn.ar(1, b.bufnum, 1);

	//in = DelayN.ar(SoundIn.ar(1), 15, 15);
	trig = Coyote.kr(in).poll;
	amp = Amplitude.kr(in, 5, 5);		
    # freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);
	freq = Demand.kr(trig, 0, Dseq(([1,2,5,3,6,7,4,8,6,9,5,8,0,12,11,13,2,1,6] + 64).midicps, inf));
    //freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
    outs = Mix.new(VarSaw.ar(freq, 0, 0.5, amp.poll));
	//Out.ar(out, (3 * IFFT(chain)).tanh.dup);
	Out.ar(out, 0.5 * outs.dup);

}).play;

)
Coyote
(


///
//Fantastiskt:::
{
var in, in2, chain, chain2;
in = VDiskIn.ar(2, c, BufSampleRate.kr(c) / SampleRate.ir);

chain2 = FFT(LocalBuf([16384, 16384]), in);
PV_MagClip(chain2, 0.01);
//PV_MagFreeze(chain2, 1);

chain = FFT(LocalBuf([256, 256]), in, 0.5);
PV_BrickWall(chain, 0.01);	
PV_MaxMagN(chain, 5);
PV_SpectralEnhance(chain, 4, 2, 0.15);
Out.ar(0, ((IFFT(chain2)*0) + IFFT(chain)).tanh);
//Out.ar(0, in);
}.play

)
c = Buffer.cueSoundFile(s,"/Users/johannes/samples/field/zoom/043-umea-nyar-februari-2009/003-ankdamm-duck-umeå-sjukhus-water-kvack-animals-stream-200902-snöknarr-birds-zoo-.wav" , 0, 2);
c.cueSoundFile("/Users/johannes/samples/field/zoom/043-umea-nyar-februari-2009/003-ankdamm-duck-umeå-sjukhus-water-kvack-animals-stream-200902-snöknarr-birds-zoo-.wav");
"/Users/johannes/samples/field/zoom/045-vietnam-feb-2012/STE-019.wav"
c.cueSoundFile("/Users/johannes/samples/field/zoom/045-vietnam-feb-2012/STE-015.wav")
c.cueSoundFile("/Users/johannes/samples/field/zoom/045-vietnam-feb-2012/STE-007.wav")
c.cueSoundFile("/Users/johannes/samples/field/zoom/045-vietnam-feb-2012/STE-027.wav")
"/Users/johannes/samples/field/zoom/045-vietnam-feb-2012/STE-027.wav"
////
