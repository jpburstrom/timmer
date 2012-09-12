Pdefn(\durGeomRit, Pgeom(0.05, 1.05, 35));
Pdefn(\durGeomRitRev, Pgeom(0.26267, 1.05.reciprocal, 35));

Pdef(\greppbrada,  Pbind(
		\instrument, 'timmer.grainPerc',
		\bufnum, ~p.s.buf.greppbrada1,
		\note, -2,
		\dur, Pdefn(\durGeomRit),
		\legato, 1.2,
		\db, Pseq([0, Pseq(5.collect(-6))], inf),
		\attack, 0.01,
		\startPos, Pseq([~p.d.gdur.frames[12], Pxrand(~p.d.gdur.frames, 5)], inf),
		\pan, 0,
		\curve, -6,
		\out, 0,
	));


Pdef(\strakArp,  Pbind(
		\instrument, 'timmer.grainPerc',
		\bufnum, ~p.s.buf.strak1,
		\root, -0.57,
		\note, [0,5,19],
		\strum, 0.1,
		\dur, 0.1,
		\legato, 10,
		\db, Pwhite(-32, -28),
		\startPos, Pwhite(0.3,0.31),
		\pan, 0,
		\curve, -2,
		\out, 0,
	));

//Denna kan användas med olika startPos, som återkommande signal.
Pdef(\strakTremoloSignal, Pbindf(Pdef(\strakArp).asPattern, \note, 0, \attack, 0.1, \dur, Pwhite(0.1,0.11)));

Pdef(\nothing,  Pbind(
		\instrument, 'timmer.grainPerc',
		\bufnum, ~p.s.buf.nothing,
		\note, -12,
		\dur, Plprand(0.01, 2),
		\legato, 1,
		\attack, 0,
		\db, 0,
		\startPos, Pwhite(),
		\pan, 0,
		\curve, -2,
		\out, 0,
	));

Pdef(\impulseString, Pbind(
		\instrument, 'timmer.impulseReal',
		\root, -6,
		\dur, Pbrown(12,15.22),
		\strum, 0.0,
		\grainlen, 2,
		\legato, 1,
		\release, 2,
		\attack, 0.8,
		\db, -18,
		\out, 0,
		\softness, 10, //Pxrand([100, 10, 5], inf), //Pwhite(0,30),//Pwhite(0.1, 0.6)
		\pwm, 0.01,
		\change, Pwhite(1),
		\bufnum, Pstutter(Pkey(\change), Pfunc( e {~p.s.bank.huff})),
		\pan, Pstutter(Pkey(\change), Pwhite(-0.5, 0.5)),
		//\env, Env(Array.rand(8, 400, 4000), Array.rand(7, 10,20), \sin)
		//\start, Pn(Penv(Array.rand(20, 0, 1.0), Array.rand(19, 1, 7.0), \sin)) * 4000 + 400
	));

Pdef(\impulseHits, Pbindf(Pdef(\impulseString).asPattern,
		\bufnum, Pstutter(Pkey(\change), Pfunc( e {~p.s.bank.hits})
	)));

Pdef(\impulseStringChords, 
	Pbindf(Pdef(\impulseString), 
			\db, -40,
			\degree, Pstutter(Pkey(\change), Pfuncn({Array.rand(3, 0, 8)}, inf)
		)));


