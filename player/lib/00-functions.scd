Fdef(\changePatternStartTime, { |amt|
	Pfuncn({ |ev|
		var thisAmt;
		if (amt.isKindOf(Symbol)) {
			thisAmt = ev[amt];
		} {
			thisAmt = amt;
		};
		ev.startPos = ev.startPos + (ev.dur * thisAmt);
		ev.dur = ev.dur * (1 - thisAmt);
		ev.dur
	}, inf)
});

Fdef(\changePatternEndTime, { |amt|
	Pfuncn({ |ev|
		var thisAmt;
		if (amt.isKindOf(Symbol)) {
			thisAmt = ev[amt];
		} {
			thisAmt = amt;
		};
		ev.dur = ev.dur * (1 - thisAmt);
		ev.dur
	}, inf)
});

Fdef(\twoPeaksPattern, { |size|
    (Pseg2([0, 0, 0.5, 0.8, 0, 0, 1, 0.7, 0],
    Pseq((size * [1,2,0.4,3,0.5,1,0.6,2].normalizeSum).floor), \cub) ++ Pn(0))
});

Fdef(\stereo2ms, { arg input, scale = -3;
    [input[0] + input[1], input[0] - input[1]] * scale.dbamp
});

Fdef(\ms2stereo, {arg mid, side, scale = -3;
    [mid - side, mid + side] * scale.dbamp;
});

Fdef(\checkBad, { arg in1, id=0;
	Select.ar(CheckBadValues.ar(in1, id, 0), [in1, DC.ar(0), DC.ar(0), in1]);
});

Fdef(\autoscale, { arg in, lo=0, hi=1, inLo=inf, inHi= -inf, rate=\kr, reset=0;
    var min = RunningMin.perform(rate, in.min(inLo), reset);
    var max = RunningMax.perform(rate, in.max(inHi), reset);
    var out = in.linlin(min, max, lo, hi);
    Select.perform(rate, min.absdif(max) > 0, [-1, out]);
});


//Scramble an array of group labels, so that two of the same label never come after each other
//Return list of indexes (offset by offset)
Fdef(\scrambleAvoidSimilar, { |labelarray, offset=0|
	var test = true;
	var i = 0;
	var output = labelarray.collect({ |x,i| [i, x] }).scramble;
	while ({i < 30 and: { test }}) {
		test = false;
		i = i + 1;
		output = output.separate({ |x,y|
			x = (x[1] == y[1]);
			if (x) { test = true };
			x
		}).collect(_.rotate(1)).flatten;
	};
	if (i < 30) {
		output.flop[0] + offset;
	} {
		nil
	}
});
