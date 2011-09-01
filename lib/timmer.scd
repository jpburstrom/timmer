//Reloading, free all bound processes
BP.freeAll;

SynthDef("timmer.grain1", { arg start, time, bufnum, rate = 1, pan = 0, amp = 1, attack = 0.001, decay = 0.02, outbus;
	var env, l, r;
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
	start = start - (attack * SampleRate.ir);	
	#l, r = PlayBuf.ar(2, bufnum, rate * BufRateScale.kr(bufnum), 1, start, 0)
		* EnvGen.kr(Env.linen(attack, time, decay), doneAction:2);
	OffsetOut.ar(outbus, Balance2.ar(l, r, pan, amp))
}).add;

//Making our own proto
PR(\basicBufferPlayer).v.clone({
		
		~def = "timmer.grain1";
		~asPattern = {
			// assume that if we're calling asPattern, we want to reset all streams
		~sendSynthDef.value;
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
		~stopCleanup = {
			"Stop".postln;
		}
}) => PR(\grainBufferPlayer);

(
make: { |name|  // |name| receives name of target BP
	//Free first, makes it easier to reload
	BP(name).free;
	PR(\grainBufferPlayer).chuck(BP(name),
	parms: (
		bufIndex: 0,
		time: Pwhite(1, 3, inf) * 0.25,
		delta: Pkey(\time),
		rate: Pwhite(0.9, 1.5, inf),
		start: Pfunc({ |ev| rrand(0.0, ~buffers[ev[\bufIndex]].duration - (ev[\time] * ev[\rate]))
			* ~buffers[ev[\bufIndex]].sampleRate }),
		amp: Pexprand(0.1, 0.9, inf),
		pan: Pwhite(-1.0, 1.0, inf),
		inChannels: 2, 
		bufPaths: ["/Volumes/Mega/projects/timmer/render/part1-samples/nr/Gnid-short-20110825-003 20110825-175629.wav",
			"/Volumes/Mega/projects/timmer/render/part1-samples/nr/Greppbrada-20110825-010 20110825-182740.wav"]
	));
	// set other parameters of BP(name) here

	// make sure to return BP(name) as the last thing in the function
	BP(name)
}, type: \bp) => Fact(\grainBufferFact);


Fact(\grainBufferFact).

Post << BP(\asd).v.buffers[0].play
	
Proto

/* 
// Fact => BP passes in the name of the target B
Fact(\grainBufferFact) => BP(\asd); 
// BP(\asd).play;

BP(\asd).play;
BP(\qwe)[\rate] = 0.5
BP(\qwe).stop(0);
*/ 


//****************
currentEnvironment