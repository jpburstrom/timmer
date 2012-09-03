//
//For NRT
//~filename = thisProcess.argv[0] ?? { "/tmp/test.wav" };

SynthDef("timmer.grain2", { arg startPos, dur, bufnum, bufRate = 1, pan = 0, amp = 1, attack = 0.1, decay = 0.02, out;
	var env, l, r;
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
	startPos = (startPos - attack) * BufFrames.kr(bufnum);	
	#l, r = PlayBuf.ar(2, bufnum, bufRate * BufRateScale.kr(bufnum), 1, startPos, 0)
		* EnvGen.kr(Env.linen(attack, dur, decay), doneAction: 2);
	OffsetOut.ar(out, Balance2.ar(l, r, pan, amp))
}).store;

(
p.stop;
p = Pproto(
	makeFunction: {
		~bufnum = (type: \allocRead, path: "/Volumes/HD2/projects/timmer/render/to SC/v2-3.3-24bit.wav").yield; //"/Volumes/HD2/projects/timmer/kod/sc/pattern-score.scd"
	},
	pattern: 
		Pfindur(300, Pseq([
		Pbind(\type, \rest, \delta, Pseq([1])),
		Pbind(
		\instrument, 'timmer.grain2',
		\type, \on,
		\distance, 1,
		\bufRate, Pwhite(0.99, 1.01),
		\dur, 0.5,
		\delta, Pbrown(0.01, 1, 0.02),
		\pan, Pxrand([-1, 0, 1], inf),
		\startPos, Pxrand(Array.fill(10, {|x| 0.0.rrand(1)}), inf) + Pwhite(-0.1, 0.1),
		//\bufnum, Pseq([d], inf),
		\amp, Pexprand(0.4, 1),
		\attack, 0.4,
		\decay, 3
		)
		])
		)).play
		//NRT .render(~filename, 310, sampleRate:48000, headerFormat: "WAV", sampleFormat: "int24", options: ServerOptions.new.numOutputBusChannels_(2), action: { 0.exit } )
 )


