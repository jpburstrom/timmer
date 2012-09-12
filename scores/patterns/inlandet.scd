(
Pdef(\carpet1, 
	Pbind(
			\instrument, 'timmer.grainPerc',
			\bufnum, ~p.getBuf(\gnid),
			\dur, Pbrown(0.1, 0.2),
			\delta, Plprand(0.005, 0.008),
			\pan, Pxrand([0], inf), 
			\bufRate, Pwrand([1,0.5], [5, 1].normalizeSum, inf),
			\startPos, Pstutter(Pwrand([1,2], [10,1].normalizeSum, inf), Pwhite()) + Pwhite(-0.01, 0.01),
			\amp, Pbrown(0.4, 2, 0.1),
			\attack, 0.1,
			\out, 0,
	);
	);
);
