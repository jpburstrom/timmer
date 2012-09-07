BP.freeType(\timmerFx);

PR(\abstractProcess).v.clone({
	
	//The effect. 
	~effect = (name: \ringmod1, func: { |sig, freq|
			SinOsc.ar(freq, 0, sig)
		});

	// FX params, dummies for now
	~freq = 800;
	
	//~fxPattern should be a pattern, which sub-PR's can define 
	~fxPattern = {
		Pbind(\freq, BPStream(\freq));
	};
	
	/****************
		Boilerplate
	*/
	~amp = 1;
	~dur = inf;
	~fx = nil;
	~alwaysReset = true;
	
	~prep = {

		// build effects by wrapping effect function in a fade in/out envelope
		SynthDef(~effect.name, { |gate = 1, amp = 0, outbus|
				var	sig = In.ar(outbus, 2),
					wetsig;
				wetsig = SynthDef.wrap(~effect[\func], nil, [sig]);
				// sig = XFade2.ar(sig, Limiter.ar(wetsig, 0.9), wetenv.madd(2, -1));
				XOut.ar(outbus, amp, wetsig);
				
		}).send(Server.default);

	};
	
	~preparePlay = {
		~fx ?? { ~chan !? { ~fx = ~chan.playfx(~effect.name.asString) }}
	};
	
	~asPattern = {
		//We bind some simple defaults, so ~fxPattern just needs to deal with the params
		Pchain( 
			~fxPattern.value,
			Pbind(\type, \set, \id, ~fx, \amp, BPStream(\amp), \dur, BPStream(\dur))
		)
	};
	
	~stopCleanup = {
		///Fade out, FIXME
		//Not a good idea, cause Node not found
		//Pbind(\type, \set, \id, ~fx, \dur, Pseq([0.1], 10), \amp, Env.cutoff(1, ~amp)).play

	};
	
	~freeCleanup = {
		~fx !? { ~fx.free; ~fx = nil }; 

	};


}) => PR(\timmerFx).subType_(\timmerFx);



/*

BP.freeType(\timmerFx)

//Preparation:

PR(\timmerBufferPlayer).v.clone({
	~bufPaths =  BP(\q).paths(\test, \Turnoff_20110825_013_20110825_175526)
}) => PR(\test_yo).subType_(\timmer);

PR(\test_yo) => BP(\test_yo_player)

BP(\test_yo_player).play(0)
BP(\test_yo_player).free
BP

Tests:
(
//Pseg - breakpoint curve (val, dur, curve type)
BP(\test).amp = Pseg(Pseq([0.001, 1], 1), 25, 'exponential') ++ Pseq([1], inf);
BP(\test).rate = 1; // Pseg(Pseq([0.6, 1], 1), 25, 'exponential');
BP(\test).time = Pseg(Pseq([0.002, 3], 1), 25, 'exponential');
BP(\test).amp = 1;
BP(\test).decay = 0.02;
//Plprand: random numbers, leaning towards the lower
BP(\test).delta_(Plprand(0.005, 1));
BP(\turnoff).play(0); 
)


BP(\test2).free
//Creating an effects bus - pass the channel of the BP
PR(\timmerFx).chuck(BP(\test2), parms: (chan: BP(\test).chan));
//Take care of playing and stopping the bus yourself
//Stop doesn't free the effect - later on we will do some nice fade-out
BP(\test2).play(0)
BP(\test2).stop(0)
BP(\test2).free


s.queryAllNodes

*/