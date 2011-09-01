//Reloading, free all bound processes
(
BP.freeAll;
//TODO: (maybe) move this to PR, or maybe not.
SynthDef("timmer.grain1", { arg start, time, bufnum, rate = 1, pan = 0, amp = 1, attack = 0.001, decay = 0.02, outbus;
	var env, l, r;
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
	start = start - (attack * SampleRate.ir);	
	#l, r = PlayBuf.ar(2, bufnum, rate * BufRateScale.kr(bufnum), 1, start, 0)
		* EnvGen.kr(Env.linen(attack, time, decay), doneAction: 2);
	OffsetOut.ar(outbus, Balance2.ar(l, r, pan, amp))
}).add;

//Making our own proto
PR(\basicBufferPlayer).v.clone({
		
		~def = "timmer.grain1";
		
		//Sensible defaults 
		~bufIndex = 0;
		//TODO: add attack + decay
		~attack = 0.01;
		~decay = 0.01;
		~time = Pwhite(1, 3, inf) * 0.25;
		~delta = Pkey(\time);
		~rate = Pwhite(0.9, 1.5, inf);
		~start = Pfunc({ |ev| rrand(0.0, ~buffers[ev[\bufIndex]].duration - (ev[\time] * ev[\rate]))
			* ~buffers[ev[\bufIndex]].sampleRate });
		~amp = Pexprand(0.1, 0.9, inf);
		~pan = Pwhite(-1.0, 1.0, inf);
		~inChannels = 2;
		~bufPaths = ["/Volumes/Mega/projects/timmer/render/part1-samples/nr/Gnid-short-20110825-003 20110825-175629.wav"];
		
		~playerPattern = {
			~argPairsStream = Pbind(*~argPairs).asStream;
			Pbind(\instrument, BPStream(\def),
				\bufIndex, BPStream(\bufIndex),
				\bufnum, Pfunc({ |ev| ~buffers[ev[\bufIndex]].bufnum }),
				\time, BPStream(\time).collect({ |time, ev| ~timeConversion.(time, ev) }),
				\rate, BPStream(\rate),
				\start, BPStream(\start),
				\amp, BPStream(\amp),
				\pan, BPStream(\pan),
				\attack, BPStream(\attack),
				\decay, BPStream(\decay),
				\chan, ~chan,
				\delta, BPStream(\delta),
				\time, Pkey(\time) / Pfunc({ thisThread.clock.tempo })
			).collect({ |ev|
				~argPairsStream !? { ev = ~argPairsStream.next(ev) };
				ev
			});	
		};
		
		//asPattern should just be calling the subpatterns, i think
		~asPattern = {
			// assume that if we're calling asPattern, we want to reset all streams
			~sendSynthDef.value;
			~playerPattern.value;
		};
		~stopCleanup = {
		};
		
		~postMCCreation = {
		}
		
}) => PR(\timmerBufferPlayer).subType_(\timmer);


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


}) => PR(\timmerFx).subType_(\timmer);

)


/*

BP.freeAll

//Preparation:
PR(\timmerBufferPlayer).chuck(BP(\test));

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
BP(\test).play(0); 
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
