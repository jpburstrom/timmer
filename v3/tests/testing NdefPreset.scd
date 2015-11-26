Ndef(\test).clear;
NdefMixer(s)
(
Ndef(\test, {
	arg freq, amp=0.1;
	SinOsc.ar(freq, 0, amp);
});
)
p = NdefPreset(\test);

//Randomize values
p.setCurr(\p1); p.setRand(0.0)
p.addSet("p1")
p.setRand(0.25)
p.addSet("p2")

//Switch to preset
p.setCurr(\p1)

//Morph between values
p.morph(0.5, \p2, \p1)

p.setCurr(\p2)
p.xfadeTo(\p1, 1, { "all done".postln })

morphFuncs

EZSlider(action: { |val| p.setCurr(\p1); p.setRand(val.value) })

[2,3].wchoose


