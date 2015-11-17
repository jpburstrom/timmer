~pitchBus = Bus.control(s);
~freqs = (36..60).midicps;
~filename = "data/multiEQ-amps.archive".resolveRelative;
~amps = Object.readArchive(~filename);
~fftbuf = Buffer.alloc(s, 2048);
~freezeBus = Bus.audio(s);

//Save
/*
~amps.writeArchive(~filename)
*/

(
Ndef(\multiEQ, {
	var snd, presnd;
	var freqs = ~freqs;
	var ctl = NamedControl.kr(\eqGain, 0 ! freqs.size);
	var amp;
	var chain;
	//--- EQ ---//
	//Steep highpass
	snd = SoundIn.ar(1);
	amp = Amplitude.ar(snd, 0.1, 0.1).lag(0.5);
	4.do { snd = HPF.ar(snd, 60) };
	//Frequencies from c1 -> c3
	freqs.do { |freq, i|
		//see http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/What-is-rq-really-td5619928.html
		//0.03125 = 1 / 16 (0.5 semitones between -3 db)
		snd = BPeakEQ.ar(snd, freq, 0.0625, \eqGain.kr[i]);
	};

	Out.ar(~freezeBus, snd);
	snd = BHiShelf.ar(snd, 300, 1, -32);


	//TODO: freeze -> processing

	//TODO: PV_
	//inte så kul, går att fixa?
	/*
	chain = FFT(LocalBuf(8192), snd);
	chain = PV_SpectralEnhance(chain, 3);
	snd = snd + IFFT(chain);
	*/

	//LFNoise -> Delay. Skoj
	//snd = snd + DelayC.ar(snd, 0.2, LFNoise2.ar(1).range(0.0, amp * 10));
	Out.kr(~pitchBus, Pitch.kr(snd));

	//Reverb. Halvkul.
	//snd = FreeVerb.ar(snd, 1, 1);

	snd = snd * 12.dbamp;

	snd = Compander.ar(snd, snd, 0.1, 1, 0.33);
	snd
}).play(2);
)

~kbd = KeyboardWindow(36, 0)
SkipJack({ ~kbd.unPressAll; ~kbd.pressNote(~freqs[~freqs.indexIn(~pitchBus.getSynchronous)].cpsmidi)}, 0.5, false, "multiEQKeyboard")
~kbd.pressNote(36)
SkipJack.stop("multiEQKeyboard")
(
//Two functions to add/subtract from currently active EQ band
~subtractFromEQ = {
	var gs = Ndef(\multiEQ).get(\eqGain);
	var freqIndex, currentFreq = ~pitchBus.getSynchronous;
	if (currentFreq < 61.midicps) {
		freqIndex = ~freqs.indexIn(~pitchBus.getSynchronous);
		gs[freqIndex] = gs[freqIndex] - 1;
		Ndef(\multiEQ).set(\eqGain, gs);
		~amps = gs;
		"Freq %, Gain is now %".format(~freqs[freqIndex], gs[freqIndex]).inform;
	}  {
		"Frequency too high" .warn
	}
};
~addToEQ = {
	var gs = Ndef(\multiEQ).get(\eqGain);
	var freqIndex, currentFreq = ~pitchBus.getSynchronous;
	if (currentFreq < 61.midicps) {
		freqIndex = ~freqs.indexIn(~pitchBus.getSynchronous);
		gs[freqIndex] = gs[freqIndex] + 0.5;
		Ndef(\multiEQ).set(\eqGain, gs);
		~amps = gs;
		"Freq %, Gain is now %".format(~freqs[freqIndex], gs[freqIndex]).inform;
	}  {
		"Frequency too high" .warn
	}
}
)


SoftStep.connect;
a = SSTrigResponder({ arg x; if (x == 1) { ~subtractFromEQ.value }}, 0, true);
b = SSTrigResponder({ arg x; if (x == 1) { ~addToEQ.value }}, 1, true);

a.free