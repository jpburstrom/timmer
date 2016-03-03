~buf = Buffer.read(s,"/Users/johannes/projects/timmer/kod/player/songs/07-Drone maskin 1 ___-44100.wav" );


(
Ndef(\fqshifttest, {
	var snd = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf) * \bufRate.kr(1), Changed.kr(\startPos.kr(60)), 44100 * \startPos.kr);
	var fq = FreqShiftAA.ar(snd, \freq.kr(-100), \phase.kr(0));
	XFade2.ar(DelayC.ar(snd, 1, \ddelay.kr(0)), DelayC.ar(fq, 1, \delay.kr(0)), \pan.kr(0));
}).play.addSpec(\freq, [-1000, 1000]).addSpec(\delay, \unipolar).addSpec(\ddelay, \unipolar).gui
)

x.free