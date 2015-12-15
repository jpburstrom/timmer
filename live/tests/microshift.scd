(
Ndef(\microshift, {
	var snd;
	var depth = 0.25; //semitones
	var speed = 0.1;
	var range = (depth/ (speed * 2)).min(1);
	var lfo = LFNoise2.ar(speed).clip2.range(0, range);
	SendReply.kr(Impulse.kr(30), '/lfo', lfo);
	snd = SinOsc.ar * 0.1;
	snd = DelayC.ar(snd, 2, lfo.poll);
	snd = [snd, SinOsc.ar(440) * 0.1]

}).play;
)
{  LFTri.ar(0.5).range(0, 1) }.plot(1)

~slider = EZSlider()

OSCdef(\lfo, { |msg| defer { ~slider.value = msg[3] }; }, \lfo);
NdefMixer(s)

2.pow(-1)

~slider.controlSpec = [0, 1].asSpec

EZSlider