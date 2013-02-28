BP.freeType(\timmerBuf);

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
		~panWidth = 1;
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
				\pan, BPStream(\pan) * BPStream(\panWidth),
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
		
}) => PR(\timmerBufferPlayer).subType_(\timmerBuf);

//Hit player
PR(\timmerBufferPlayer).v.clone({
		~def = "timmer.hit";
		
		//TODO: add attack + decay
		~attack = 0.01;
		~decay = 0.01;
		~time =  Pbrown(0.02, 0.1);
		~delta = Pkey(\time);
		~rate = 1;
		~amp = Pexprand(0.1, 0.9, inf);
		~pan = Pwhite(-1.0, 1.0, inf);
		~bufIndex = Pwhite(0, Pfunc({ |ev| ~bufPaths.size - 1 }));
		~bufPaths = nil;

		
		~playerPattern = {
			~argPairsStream = Pbind(*~argPairs).asStream;
			Pbind(
				\instrument, BPStream(\def),
				\bufIndex, BPStream(\bufIndex),
				\bufnum, Pfunc({ |ev| ~buffers[ev[\bufIndex]].bufnum; }),
				\attack, BPStream(\attack),
				\decay, BPStream(\decay),
				\time, BPStream(\time).collect({ |time, ev| ~timeConversion.(time, ev);}),
				\rate, BPStream(\rate),
				\amp, BPStream(\amp),
				\pan, BPStream(\pan) * BPStream(\panWidth),
				\chan, ~chan,
				\delta, BPStream(\delta),
				\time, Pkey(\time) / Pfunc({ thisThread.clock.tempo })
			).collect({ |ev|
				~argPairsStream !? { ev = ~argPairsStream.next(ev) };
				ev
			});	
		};
}) => PR(\timmerHitPlayer).subType_(\timmerBuf);

PR(\timmerHitPlayer).v.clone({
	
	~time = 1;
	~pan = 0;
	~amp = 1;
	~decay = 0.1;
	
	~reloadBufIndex = {
		~bufIndex = Pshuf((0..~bufPaths.size - 1), inf)
	}; 
	//Yes
	~timeConversion = { |time, ev|
		var buf = ~buffers[ev[\bufIndex]];
		//~bufPaths.size.postln;
		//ev.postln;
		time = (time * buf.numFrames / buf.sampleRate) - ev.decay;
	}

}) => PR(\timmerHuffPlayer).subType_(\timmerBuf);




/*
BP(\test).free
s.reboot
PR(\test) => BP(\test)
BP(\test).play(0)
BP(\test).stop(0)
BP(\test).attack = 0.1
BP(\test).decay = Pkey(\delta


BP(\test).delta = Pkey(\time); 
BP(\test2).play(0); BP(\test).play(0)


BP(\test).decay = 0.1
BP(\test).time = 0.1
BP(\test).bufIndex = Pwhite(0, BP(\test).bufPaths.size);
BP(\test).panWidth = 0

PR(\timmerHitPlayer) => BP(\test)
BP(\test).bufPaths = BP(\q).s.banks.hits.collect(_.path)
BP(\q).paths(\banks, \hits)


PShuffle
//A test, making another PR
PR(\timmerBufferPlayer).v.clone({
	~bufPaths =  BP(\q).paths(\test, \Turnoff_20110825_013_20110825_175526)
}) => PR(\test_yo).subType_(\timmerBuf);
*/

/*

BP.freeType(\timmerBuf)

//Preparation:

n = BP(\test).v.bufPaths
n.next


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
