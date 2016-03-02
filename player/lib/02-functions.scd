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