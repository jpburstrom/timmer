y = Buffer.alloc(s, (1024 * 2) + 3);

(
Ndef(\test, {
	var winsize = 4096;
	var copy, chain, subtractor, snd = SoundIn.ar(1);
	var freq = 400;
	var wipe = (2 * freq * SampleDur.ir) - 1;


	//--- EQ ---//
	//Steep highpass
	4.do { snd = HPF.ar(snd, 60) };
	/*48000
	snd = BPeakEQ.ar(snd, 277, 0.1, -9.5);
	snd = BPeakEQ.ar(snd, 110, 0.1, -5.25);
	snd = BPeakEQ.ar(snd, 220, 0.1, -8.25);
	snd = BHiShelf.ar(snd, 300, 1, -32);
	*/
	snd = BPeakEQ.ar(snd, 56, 0.1, -24);

	snd = BPeakEQ.ar(snd, 87, 0.1, -6);
	snd = BPeakEQ.ar(snd, 110, 0.1, -16);
	snd = BPeakEQ.ar(snd, 146, 0.1, -12);
	snd = BPeakEQ.ar(snd, 180, 0.1, -6);
	snd = BPeakEQ.ar(snd, 220, 0.1, -6);
	snd = BPeakEQ.ar(snd, 240, 0.1, -9);
	snd = BPeakEQ.ar(snd, 258, 0.1, -9);

	snd = BHiShelf.ar(snd, 400, 1, -32);

	snd = snd * 12.dbamp;
	//snd = FreqShift.ar(snd, 10);
	//snd = SinOsc.ar(LFNoise2.ar(1).exprange(200, 400)) * 0.05;
	chain = FFT(LocalBuf(winsize), snd);
	//Prepared convolution of bass
	//chain = PV_MagSubtract(chain, ~bassPrint);
	//chain = PV_BrickWall(chain, wipe);
	/*
	subtractor = PV_Copy(chain, LocalBuf(winsize));
	subtractor = PV_MagFreeze(subtractor, \freeze.kr(0));
	subtractor = PV_MagMulAdd(subtractor, \freeze.kr * 0.5);
	chain = PV_MagSubtract(chain, subtractor, 1);
	*/
	//see http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/fft-max-mag-formula-td4654734.html
	chain = PV_MagAbove(chain, 10);
//	chain = PV_Diffuser(chain, Impulse.kr(0.5));
	chain = PV_LocalMax(chain, 0.1);
	//chain = PV_MaxMagN(chain, 1);

	//TODO: 4 kopior

	//Smooth > Freeze
	chain = PV_MagSmooth(chain, \smooth.kr(0.5));

	chain = PV_Compander(chain, 20, 1, 0.33);

	//snd = IFFT(chain);
	//snd = Compander.ar(snd, snd, 0.1, 1, 0.33);
	snd
}).play(2);
)
Ndef(\test).end
Cepstrum
PV_Invert
Ndef(\test2, {
	var chain = PV_PlayBuf(LocalBuf(1024, 1), y, 1, loop:1);
//	chain = PV_MagSmooth(chain, 0.1);
//	chain = PV_MagShift(chain, 2);
	chain = PV_PhaseShift(chain, LFNoise2.kr(1, 180, 180));
	IFFT(chain);
});
Ndef(\test2).play(0)
Ndef(\test2).end

{ SinOsc.ar(MouseX.kr(100, 300).poll) * 0.05 }.play

~meq = MasterEQ(3)
~meq.start
x = { LPF.ar(Impulse.ar(1))* 4}.play(outbus:2)
x.free
Post << ~meq.eq

//PV_Freeze Freezes magnitudes at current levels when freeze > 0, and advances phase according to difference between frames to try and maintain currect spectral quality.
Ndef(\test).scope

s.options.hardwareBufferSize = 64
s.options.sampleRate
SoftStep.connect
a = SSToggleResponder({ arg val; if (val == 1) { Ndef(\test2).play(0) } { Ndef(\test2).stop } }, 0, true);
a.free

~cbus = Bus(\control, 1, 1, s);
~frequencies = List();
~makeSynth = {
	~eqSynth.free;
	~eqSynth = {
		var snd = In.ar(2);
		~frequencies.do { |x, i| snd = BPeakEQ.ar(snd, x, 0.1, -6); };
		ReplaceOut.ar(2, snd);
	}.play(addAction:\addToTail);
};
~newFreq = {
	var freq = ~cbus.getSynchronous;
	freq.debug("freq");
	~frequencies.add(freq);
	~makeSynth.value;
}

~cbus.getSynchronous
~newFreq.value

~frequencies

a = SSToggleResponder(~newFreq, 0, true);
a.free