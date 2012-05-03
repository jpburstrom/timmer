"This is Sonny".postln;
~timmer.bus.postln;
~sonny = Proto({
	
	~group = Group(addAction:\addToHead);
	
	~prePrep = {
		~sonnyBus.free;
		~sonnyBuffer.free;
		
		~sonnyBus = Bus.audio(s);
		~sonnyBuffer = Buffer.alloc(s, s.sampleRate * 60); // 
		SynthDef(\sonnyRec, { |chan=0, buf=0, bus=16|
			var phaseR;
			phaseR = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
			BufWr.ar(SoundIn.ar(chan, 1), buf, phaseR, 1);
			Out.ar(bus, phaseR);
		}).add;
		
		SynthDef(\sonnyPlay, { |gate=1, rate=0.95, amp=1, attack=0.1, release=4.0, out=0,buf=0, bus=16|
			var phaseP, sound;
			phaseP = Phasor.ar(Impulse.kr(0), BufRateScale.kr(buf)*rate, 0, BufFrames.kr(buf), In.ar(bus) - 100);
			sound = BufRd.ar(1, buf, phaseP, 1, 4) * EnvGen.kr(Env.asr(attack, amp, release), gate, doneAction:2);
			Out.ar(out, sound);
		}).add;
		
	};	
	
	~prep = {
		~freeAll.();
		~sonnyRec = Synth(\sonnyRec, [\buf, ~sonnyBuffer, \bus, ~sonnyBus], ~group, addAction:\addToHead);
		~sonnyPlay = nil;
		MIDIdef.cc(\sonnyPedal, {|val| 
			if ( val == 0, 
				{ ~sonny.sonnyPlay = Synth(\sonnyPlay, [\out, ~timmer.bus, \buf, ~sonny.sonnyBuffer, \bus, ~sonny.sonnyBus], ~sonny.group, addAction: \addToTail)},
				{ ~sonny.sonnyPlay.set(\gate, 0) }
				)
		}, 64);
	};
	
	~freeAll = {
		~sonnyRec.free; ~sonnyPlay.free;
	}
});

{
	s.sync;
	~sonny.prePrep;
	s.sync;
	~sonny.prep;
}.fork