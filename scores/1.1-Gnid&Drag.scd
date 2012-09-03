/*
Solobakgrund.
*/
//For NRT
//~filename = thisProcess.argv[0] ?? { "/tmp/test.wav" };

(
s.waitForBoot {
	~p !? { ~p.freeAll }; 
	~p = Proto();
	~p.s = ();
	~p.s.currentPath = "/Volumes/HD2/projects/timmer/kod/sc/scores/";
	(~p.s.currentPath ++ "lib/*").loadPaths;

	~p.addPrep( \gnid1, e {
		~p.readBuffer(\gnid, "/Volumes/HD2/projects/timmer/render/part1-samples/nr/Gnid-20110825-002-nr.wav");
	});

	//Add some synths
	~p.addPrep(\gnid, e {
		~p.playSynth(\delay, \bitCrushDelay,  
			[\in, ~p.s.bus.delay, \aux1, ~p.s.bus.reverb], s, \addToTail);
		~p.playSynth(\room1, \stereoConvReverb,  
			[\in, ~p.s.bus.reverb, 
				\bufL, ~p.s.buf[\room1_bufL], \bufR, ~p.s.buf[\room1_bufR]], 
			s, \addToTail)
	}, 0); //A priority of 0 makes it restart on cmd-period.

	~p.prep;

}
)

Env().plot
//
//PATTERN DEFINITIONS
//

~p.carpet1 = Pbind(
		\instrument, 'timmer.grain3',
		\bufnum, ~p.getBuf(\gnid),
		\type, \on,
		\dur, Pbrown(0.1, 0.2),
		\delta, Plprand(0.005, 0.008),
		\pan, Pxrand([0], inf), 
		\bufRate, Pwrand([1,0.5], [5, 1].normalizeSum, inf),
		\startPos, Pstutter(Pwrand([1,2], [10,1].normalizeSum, inf), Pwhite()) + Pwhite(-0.01, 0.01),
		\amp, Pbrown(0.4, 2, 0.1),
		\attack, 0.1,
		\out, 0,
);
~p.carpet2 = Pbindf(~p.carpet1, \bufRate, 0.5, \amp, 0.1);

(
~p.hejhej = Pbind(
	\instrument, 'timmer.grain3',
	\bufnum, ~p.getBuf(\gnid),
	\type, \on,
	\dur, Pbrown(0.01, 0.9),
	\delta, Plprand(0.05, 1),
	\pan, Pxrand([0], inf),
	\bufRate, Pwrand([1,5,0.5], [10, 1, 1].normalizeSum, inf),//Pkey(\delta) * 2 ,
	\startPos, Pstutter(Pwrand([1,2], [10,1].normalizeSum, inf), Pwhite()) + Pwhite(-0.01, 0.01),//Pxrand(Array.fill(10, {|x| 0.0.rrand(1)}), inf) + Pwhite(-0.1, 0.1),
	\amp, Pexprand(0.4, 1),
	\attack, 0.1,
	\aux1, ~p.getBus(\delay),
	\out, ~p.getBus(\devnull)
).play;
);

~p.delay1 = Pbind(*[type: \set,
	\id, ~p.getSyn(\delay),
	feedback: Pexprand(0.5, 0.99),
	length: Pexprand(0.01, 0.1),
	resolution: Pwhite(12, 24),
	args: #[\feedback, \length, \resolution],
	dur: Pbrown(1, 10),
]);


Pdef(\carpet1, ~p.carpet1).play
~p.carpet1.asStream.nextN(29, ());
Pdef(\carpet1, PFF(~p.carpet1, 20, 1)).play
Pdef(\carpet1, ~p.carpet1).fadeTime = 2
Pdef(\carpet1, ~p.hejhej).play
Pdef(\delay, ~p.delay1).play
~p.carpet1.play
~p.carpet2.play
~p.hejhej.play
~p.delay1.play

//
//SCORE
//

Pn((Pfindur(1, ~p.carpet1) ++ Pfindur({2.rrand(5)}, ~p.carpet2))).play

MasterEQ
ddwEQ
Quarks.gui


StaticEQ().edit
