{ SelectX.ar(TIRand.kr(0, 1, Impulse.kr(10)), [SinOsc.ar(220), SinOsc.ar(440)]) * 0.1 }.play
{ LinSelectX.ar((TIRand.kr(0, 1, Impulse.kr(10)) * 2 - 1).poll, [SinOsc.ar(220), SinOsc.ar(440)]) * 0.1 }.play

(
	*new1 { arg rate, which, array;
		var selector = UGen.methodSelectorForRate(rate);
		^this.crossfadeClass.perform(selector,
			Select.perform(selector, which.round(2), array),
			Select.perform(selector, which.trunc(2) + 1, array),
			(which * 2 - 1).fold2(1)
		);
	}
)

(
var test = { arg which, array;
	LinXFade2.ar(Select.ar(which.round(2), array),
		Select.ar(which.trunc(2) + 1, array);
		(which * 2 - 1).fold2(1)
	);
};

{ test.(TIRand.kr(0, 1, Impulse.kr(10)) * 2 - 1, [SinOsc.ar(220), SinOsc.ar(440)]) * 0.1 }.play

)

UGen.methodSelectorForRate(\ar)
{ SinOsc.perform(\audio) * 0.1 }.play