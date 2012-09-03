//
//For NRT
//~filename = thisProcess.argv[0] ?? { "/tmp/test.wav" };

//TODO:
//Midi sine
//

(
//INIT

SynthDef("timmer.grain4", { arg startPos, dur, bufnum, bufRate = 1, pan = 0, amp = 1, attack = 0.1, decay = 0.02, curve= -8, out;
	var env, l, r;
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
	startPos = (startPos) * BufFrames.kr(bufnum);	
	#l, r = PlayBuf.ar(2, bufnum, bufRate * BufRateScale.kr(bufnum), 1, startPos, 0)
		* EnvGen.kr(Env.perc(attack, dur, curve:curve), doneAction: 2);
	OffsetOut.ar(out, Balance2.ar(l, r, pan, amp))
}).store;

SynthDef(\timmer31, { |freq, amp, gate=1|
	var son, inamp;
	son = SoundIn.ar([0,1]);
	inamp = Amplitude.ar(son, 0.1, 0.1);
	Out.ar(0, SinOsc.ar(freq, mul: amp) * EnvGen.kr(Env.asr(0.01, 1, 0.01), gate, doneAction:2) * inamp);
}).add;

SynthDef(\timmer312, { |freq, amp, gate=1|
	Out.ar(0, SinOsc.ar(freq, mul: amp) * EnvGen.kr(Env.adsr(decayTime:0.05, sustainLevel: 0.1, releaseTime:0) , gate, doneAction:2));
}).add;

~scmirfile = SCMIRAudioFile("/Volumes/HD2/projects/timmer/render/to SC/v2-3.1-first shots - SC test 24 bit.wav").extractOnsets;
~onsets = (~scmirfile.onsetdata) / ~scmirfile.duration;
~birds = [12,12,12,16,16,24,24,24,4,8,64,32,62.060606];

~timmer31 = Proto.new({

	~doMidiNotes = {
		var notes, on, off;
		
		notes = Array.newClear(128); Ê Ê// array has one slot per possible MIDI note
	
		on = MIDIFunc.noteOn({ |veloc, num, chan, src|
	Ê 
		notes[num] = Synth(\timmer31, [\freq, (num - 0.05).midicps,
			
		Ê Ê Ê Ê \amp, veloc * 0.00315]);
		});
		
		off = MIDIFunc.noteOff({ |veloc, num, chan, src|
			("off" + num).postln;
		Ê Ê notes[num].release;
		});
		
		~panic = {Ênotes.do(_.release) };
		~freeMidi = { on.free; off.free; };
	
	}
	
});

MIDIIn.connect;
~timmer31.doMidiNotes;

)


(
p.stop;
p = Pproto(
	makeFunction: {
		~bufnum = (type: \allocRead, path:"/Volumes/HD2/projects/timmer/render/to SC/v2-3.1-first shots - SC test 24 bit.wav" ).yield; //"/Volumes/HD2/projects/timmer/kod/sc/pattern-score.scd"
	},
	pattern: 
		Pfindur(300, Pseq([
		Pbind(\type, \rest, \delta, Pseq([1])),
		Pbind(
		\instrument, 'timmer.grain4',
		\type, \on,
		\bufRate, Pwrand([Pwhite(1.98, 2.01, 1),Pwhite(1.6, 1.61, 1), Pwhite(1.2, 1.21, 1)], [10, 2, 6].normalizeSum, inf) * 0.65,
		\dur, 2.55,
		\delta, Pwrand([Pbrown(0.2, 1, 0.5, 4),  Pwhite(1.8, 2.2) / Pseq(~birds, 1), Pseq(Array.geom(20, 1, 1.1).reciprocal ++ Pwhite(0.5,1,1), 1)], [10, 5, 2].normalizeSum, inf),
		//\delta, Pseq(Array.geom(20, 1, 1.2).reciprocal),
		\startPos, Pstutter(Pwhite(1,2), Pxrand(~onsets, inf)) - Pwhite(0, 0.001),
		\pan, Pkey(\startPos) * 2 - 1 * 0,
		//\bufnum, Pseq([d], inf),
		\amp, Plag(10, Pexprand(0.1, 2)),
		\attack, 0.05,
		\curve, Pwhite(-48, -24),
		\out, 2
		)
		])
		)).play
		//NRT .render(~filename, 310, sampleRate:48000, headerFormat: "WAV", sampleFormat: "int24", options: ServerOptions.new.numOutputBusChannels_(2), action: { 0.exit } )
)


//TESTING...

(
Pproto(
	makeFunction: {
		~bufnum = (type: \allocRead, path:"/Volumes/HD2/projects/timmer/render/to SC/v2-3.1-first shots - SC test 24 bit.wav" ).yield; //"/Volumes/HD2/projects/timmer/kod/sc/pattern-score.scd"
	},
	pattern: 
		Pfindur(300, Pseq([
		Pbind(\type, \rest, \delta, Pseq([1])),
		Ppar([
		Pbind(
		\instrument, 'timmer.grain4',
		\type, \on,
		\bufRate, Pwrand([Pwhite(1.98, 2.01, 1),Pwhite(1.6, 1.61, 1), Pwhite(1.2, 1.21, 1)], [10, 2, 6].normalizeSum, inf) * 0.65,
		\dur, 2.55,
		\delta, 2 / Pseq(~birds, inf),
		//\delta, Pseq(Array.geom(20, 1, 1.2).reciprocal),
		\startPos, Pstutter(Pwhite(1,2), Pxrand(~onsets, inf)) - Pwhite(0, 0.001),
		\pan, Pkey(\startPos) * 2 - 1 * 0,
		//\bufnum, Pseq([d], inf),
		\amp, Plag(10, Pexprand(0.1, 2)),
		\attack, 0.05,
		\curve, Pwhite(-48, -24),
		\out, 3
		),
		Pbind(
		\instrument, 'timmer312',
		\type, \note,
		\dur, 2 / Pseq(~birds, inf),
		\legato, 1,
		//\delta, Pseq(Array.geom(20, 1, 1.2).reciprocal),
		//\bufnum, Pseq([d], inf),
		\amp, 0.01,
		//\out, 3,
		\freq, Pwhite(92, 100.0).midicps
		) ])
		])
		)
		//NRT .render(~filename, 310, sampleRate:48000, headerFormat: "WAV", sampleFormat: "int24", options: ServerOptions.new.numOutputBusChannels_(2), action: { 0.exit } )
).play
)