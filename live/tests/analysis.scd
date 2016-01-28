(
SynthDef(\fftod, {
    var source1, detect;
    source1= SoundIn.ar(1);
    detect= PV_HainsworthFoote.ar(FFT(LocalBuf(2048),source1), 1.0, 0, 2, 0.1 );
    Out.ar(0,SinOsc.ar([440,445],0,Decay.ar(0.1*detect,0.1)));
}).play(s);
)


(
Ndef(\analysis, {
	arg threshold=0.3, relaxtime=2, retrigTime=0.1, floor=0.5;
	var snd, chain, onsets, buf = LocalBuf(512);
	var amp, ampLong, ampLongWindow=1, simpleGate;
	var freq, hasFreq;
	var silence;
	snd = SoundIn.ar(1);

	//AMP
	amp = Amplitude.kr(snd, 0.01, 1);
	simpleGate = (amp > 0.005);

	//AMP TILT
	ampLongWindow = ControlRate.ir * ampLongWindow;
	ampLong = RunningSum.kr(amp, ampLongWindow) / ampLongWindow;
	ampLong = simpleGate * ((((amp - ampLong).abs) * \longAmpScale.kr(2.5)).min(1).max(0)); //Roughly scale the value from 0-1


	//ONSETS
	chain = FFT(buf, snd);
	onsets = Onsets.kr(chain, threshold, \wphase, relaxtime: relaxtime, floor:floor);
	onsets = onsets * simpleGate;

	//PITCH
	#freq, hasFreq = Tartini.kr(snd);

	//SILENCE
	silence = simpleGate.lagud(0.05, 1) < 1;

	SendReply.kr(TDelay.kr(onsets, 0.1);, '/freq', freq);
	SendReply.kr(Impulse.kr(30), '/amp', [amp, ampLong]);
	SendReply.kr(onsets, '/onset', [amp, ampLong]);
	SendReply.kr(silence, '/silence', [ampLong]);

	[onsets, amp, ampLong, freq];
});
)

0.reciprocal
~slider = Slider()
~slider.front
~slider.value = 1
~sliderMax = 0;
~autoScale = RedAutoScale();
OSCdef(\amp, { |msg| { ~slider.value = msg[4]  }.defer  }, '/amp');

~kbd = KeyboardWindow(36, 0);
OSCdef(\pitch, { |msg| { ~kbd.unPressAll; ~kbd.pressNote(msg[3].cpsmidi) }.defer }, '/freq');
OSCdef(\pitch).free


OSCdef(\silence, { |msg| { SinOsc.ar * 0.1 * EnvGen.ar(Env.perc, doneAction:2) }.play }, '/silence');
OSCdef(\silence).free
