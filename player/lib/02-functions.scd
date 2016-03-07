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
    in.linlin(RunningMin.perform(rate, in.min(inLo), reset), RunningMax.perform(rate, in.max(inHi), reset), lo, hi)
});
