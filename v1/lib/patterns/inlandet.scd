(
Pbindef(\carpet1,
    \instrument, 'timmer.grainPerc', //FIXME
    \bufnum, q.pBuf(\gnid),
    \dur, Plprand(0.005, 0.008),
    \legato, 10,
    \pan, 0,
    \harmonic, 1,
    \startPos, Pstutter(Pwrand([1,10], [10,1].normalizeSum, inf), Pwhite()) + Pwhite(-0.01, 0.01),
    \db, -18,
    \attack, 0.001,
    \out, 0,
	);
)
;

Pdef(\carpet1Low,
    Pbindf(Psym(\carpet1).source,
        \harmonic, Pwrand([0.5, 1], [50,2].normalizeSum, inf)
    )
);

Pdef(\carpet1Stop,
    Pbindf(
        Psym(\carpet1).source,
        \dur, Pdefn(\durGeomRitLong)
    ).finDur(6)
);

Pbindef(\strokes,
    \instrument, 'timmer.grainPerc', //FIXME
	\bufnum, q.pBuf(\gnid),
	\dur, Pbrown(0.01, 0.9),
	\delta, Plprand(0.05, 1),
	\pan, Pxrand([0], inf),
	\bufRate, Pwrand([1,5,0.5], [10, 1, 1].normalizeSum, inf),//Pkey(\delta) * 2 ,
	\startPos, Pstutter(Pwrand([1,2], [10,1].normalizeSum, inf), Pwhite()) + Pwhite(-0.01, 0.01),//Pxrand(Array.fill(10, {|x| 0.0.rrand(1)}), inf) + Pwhite(-0.1, 0.1),
	\amp, Pexprand(0.4, 1),
	\attack, 0.1,
    // \aux1, ~p.getBus(\delay),
    // \out, ~p.getBus(\devnull)
);

Pbindef(\delayRider,
    \type, \set,
	\id, q.pFx(\delay), //FIXME
	\feedback, Pexprand(0.5, 0.99),
	\length, Pexprand(0.01, 0.1),
	\resolution, Pwhite(12, 24),
	\args, #[\feedback, \length, \resolution],
	\dur, Pbrown(1, 10),
);


