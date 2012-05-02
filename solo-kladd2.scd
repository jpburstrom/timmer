(
//Server.local.options.device = "JackRouter";
s.waitForBoot {
	BP.freeAll;
	
	~dir = ();
	~q = ();
	~dir.project = "/Volumes/HD2/projects/timmer/kod/sc/";
	~dir.lib = ~dir.project ++ "lib/";
	
	//Load lib files 
	
	(~dir.lib ++ "*").loadPaths;
}
)


b = Buffer.cueSoundFile(s,"/Volumes/HD2/projects/timmer/creations/solo-kladdtest/01-120428_1727.wav" , 0, 1);
c = Buffer.cueSoundFile(s,"/Users/johannes/samples/field/zoom/032-torpet-natur-tyst-walking/001-birds-summer-insects-happy-environment-insect_flying_by.wav" , 0, 2);
(
SynthDef(\soloNoiseKladd, { |bus, bufnum=0, gate=1, rate=0.7, amp=1, attack=0.1, release=1.0, out=0, offset=0|
	var in, trig, decay, outs, freq, hasFreq;
	in = SoundIn.ar(1);
	trig = Coyote.kr(in);
	# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);
	amp = Amplitude.kr(in, 5, 5);		
	decay = Demand.kr(trig, 0, Dseq(~q.d.swed019w, inf));
	outs = Dust.ar(20) * EnvGen.kr(Env.perc( 0.01, decay, amp*6), trig);
	outs = BPF.ar(outs, 110, 10);
	//Out.ar(out, (3 * IFFT(chain)).tanh.dup);
	outs.poll;
	Out.ar(out, 1 * outs.dup);

}).play;
)
s.meter
(
SynthDef(\soloKladd, { |bus, bufnum=0, gate=1, rate=0.7, amp=1, attack=0.1, release=1.0, out=0, offset=0|
	var phaseP, sound, in, chain, onsetChain, freq, hasFreq, outs, trig;
	//in = DiskIn.ar(1, b.bufnum, 1);
	in = SoundIn.ar(1);
	//phaseP = Phasor.ar(Impulse.kr(0), BufRateScale.kr(bufnum)*rate, 0, BufFrames.kr(bufnum), In.ar(bus) - 100);
	//in = BufRd.ar(1, bufnum, phaseP, 1) * EnvGen.kr(Env.asr(attack, amp, release), gate, doneAction:2);
	
	//in = DelayN.ar(SoundIn.ar(1), 15, 15);
	trig = Coyote.kr(in);
	amp = Amplitude.kr(in, 5, 5);		
    # freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);
	freq = Demand.kr(trig, 0, Dseq((~q.d.swed019w * 32 + 50).round.midicps, inf));
    //freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
    outs = Mix.new(SinOsc.ar(freq, mul:amp), MdaPiano.ar(freq, trig, release:2, mul:amp));
	//Out.ar(out, (3 * IFFT(chain)).tanh.dup);
	Out.ar(out, 0.5 * outs.dup);

}).play(s, [\offset: 80]);
)
s.boot
MdaPiano
Array

(
///
//Fantastiskt:::
{
var in, in2, chain, chain2;
in = VDiskIn.ar(2, c, BufSampleRate.kr(c) / SampleRate.ir, 1);
//in = SoundIn.ar(1);
//in = DelayN.ar(in,10,10);
chain2 = FFT(LocalBuf([16384,16384]), in);
PV_MagClip(chain2, 0.01);
//PV_MagFreeze(chain2, 1);

chain = FFT(LocalBuf([128,128]), in, 0.5);
PV_BrickWall(chain, 0.01);	
PV_MaxMagN(chain, 8);
PV_SpectralEnhance(chain, 4, 3, 0.35);

Out.ar(0, ((IFFT(chain2)*0.3) + IFFT(chain) * 3).tanh * 0.2);
//Out.ar(0, in);
}.play

)
c = Buffer.cueSoundFile(s,"/Users/johannes/samples/field/zoom/043-umea-nyar-februari-2009/003-ankdamm-duck-umeå-sjukhus-water-kvack-animals-stream-200902-snöknarr-birds-zoo-.wav" , 0, 2);
c.cueSoundFile("/Users/johannes/samples/field/zoom/042-lulea-vasterbotten/010-sly-träsk-water-foot-bra-sly-bra.wav");
c.cueSoundFile("/Users/johannes/samples/field/zoom/032-torpet-natur-tyst-walking/001-birds-summer-insects-happy-environment-insect_flying_by.wav");
c.cueSoundFile("/Users/johannes/samples/field/zoom/043-umea-nyar-februari-2009/003-ankdamm-duck-umeå-sjukhus-water-kvack-animals-stream-200902-snöknarr-birds-zoo-.wav");
"/Users/johannes/samples/field/zoom/045-vietnam-feb-2012/STE-019.wav"
c.cueSoundFile("/Users/johannes/samples/field/zoom/045-vietnam-feb-2012/STE-015.wav")
c.cueSoundFile("/Users/johannes/samples/field/zoom/045-vietnam-feb-2012/STE-007.wav")
c.cueSoundFile("/Users/johannes/samples/field/zoom/045-vietnam-feb-2012/STE-027.wav")
"/Users/johannes/samples/field/zoom/045-vietnam-feb-2012/STE-027.wav"
////
