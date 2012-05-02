(

PR(\abstractProcess).v.clone({
	
	~bus = nil;
	~buf = nil;
	~server = s;
	
	~toFree = List();
	
	~attack = 0.1;
	~release = 1.0;
	~amp = 1;
	~rate = 0.8;
	~delta = 1;
	~legato = 1;
	
	~argPairs = [];	// there must be a default or ~argPairsStream fails
	~postMCCreation = nil;		// put in your own user preparation func here
	~timeConversion = { |time, ev| time };
	~argPairs_ = { |args|
		~argPairs = args;
		~argPairsStream = Pbind(*~argPairs).asStream;
	};
	
	~initBuffer = {
		"initing buffers".postln;
		~buf = Buffer.alloc(~server, 4800000);
		~bus = Bus.audio(~server);
		~toFree.add(~bus).add(~buf);
	};
	
	~initSynths = {
		e {
		// Recording synth
		SynthDef(\sonnyRec, { |bus=16, bufnum=0|
			var phaseR, chan=1;
			phaseR = Phasor.ar(0, BufRateScale.kr(bufnum), 0, BufFrames.kr(bufnum));
			BufWr.ar(SoundIn.ar(chan, 1), bufnum, phaseR, 1);
			Out.ar(bus, phaseR);
		}).send(~server);
		
		// Playback synth
		SynthDef(\sonnyPlay, { |bus, bufnum=0, gate=1, rate=0.95, amp=1, attack=0.1, release=1.0, out=0|
			var phaseP, sound;
			phaseP = Phasor.ar(Impulse.kr(0), BufRateScale.kr(bufnum)*rate, 0, BufFrames.kr(bufnum), In.ar(bus) - 100);
			sound = BufRd.ar(1, bufnum, phaseP, 1) * EnvGen.kr(Env.asr(attack, amp, release), gate, doneAction:2);
			Out.ar(out, sound);
		}).add;

		~server.sync;
		
		~recorder = Synth.new(\sonnyRec, [bufnum: ~buf, bus: ~bus], ~server);
		//~player = Synth.tail(~server, \sonnyPlay, [bufnum: ~buf, bus: ~bus], ~server);
		~toFree.add(~recorder); //.add(~player);
		}.fork	
	};
	
	//Oh yes, we're freeing stuff.
	~freeCleanup = {
		//~toFree.do (_.free);
	};
	
	~prep = {
		~initBuffer.(); 
		~initSynths.();
	};
	
	~asPattern = {
		~argPairsStream = Pbind(*~argPairs).asStream;
		Pbind(
			\instrument, \sonnyPlay,
			\bus, BPStream(\bus),
			\bufnum, BPStream(\buf),
			\amp, BPStream(\amp),
			\rate, BPStream(\rate),
			\attack, BPStream(\attack),
			\release, BPStream(\release),
			\delta, BPStream(\delta),
			\legato, BPStream(\legato),
			\addAction, 1
		).collect({ |ev|
			~argPairsStream !? { ev = ~argPairsStream.next(ev) };
			ev			
		});	
	
	}
	
}) => PR(\sonny)

)
//Do stuff
BP.freeAll
PR(\sonny) => BP(\sonnyTest)
BP(\sonnyTest).play(0)
BP(\sonnyTest).stop
BP(\sonnyTest).amp = 0.7
BP(\sonnyTest).rate = 0.88
BP(\sonnyTest).delta = 10
BP(\sonnyTest).release = 0.01
BP(\sonnyTest).legato = 10
BP(\sonnyTest).rate = 0.7

s.queryAllNodes




