
//## Initialize ###
(
"lib/init".import;
q.player.actionLabels = #[part];
q.player.tickLabel = \part;
q.player.loadData("11");
//q.player.extractFeatures;
q.playerui.connect(q.player);
)
(
//## Patterns #######

//## Callbacks ####
//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar
q.player.onReady = {
	~t.reverb = Synth(\plate_reverb_2x2, [\amp, -12.dbamp, \decay, 0.1], ~t.sendGroup);

	~t.zerox_envbus = Bus.control;
	~t.zerox_outbus = Bus.audio(s, 2);
	~t.posbus = Bus.audio;
	~t.sndbuf = Buffer.alloc(s, 10*s.sampleRate, 2);
	~t.timebuf = Buffer.alloc(s, 10*s.sampleRate);
	~t.zerox_rec = Synth(\zerox_delay_rec_2, [\inbus, 0, \posbus, ~t.posbus, \sndbuf, ~t.sndbuf, \timebuf, ~t.timebuf], ~t.postGroup);
    //We use an outbus for the zerox to be able to read several times from the same bus
	~t.zerox_mix = { Out.ar(0, In.ar(~t.zerox_outbus, 2)) }.play(target:~t.sendGroup);
	s.sync;

};

//This sets a pattern used to modify the base player pattern.
q.player.setPtn(Pbind(
	\dummy, Pfunc { |ev|
		var partDur = ~data.part[ev.part][1];
		var createDelays = { |num, key, amp, pan|
			~t[key] = num.collect { |i|
				pan = (pan ? { i / (num - 1) }).value(i, num);
				amp = amp ?? { -12.dbamp };
				Synth(\zerox_delay_2x2,
					[\inbus, 0, \outbus, ~t.zerox_outbus, \posbus, ~t.posbus, \sndbuf, ~t.sndbuf,
						\timebuf, ~t.timebuf, \pan, pan, \amp, amp, \attackTime, 1.rrand(3.0)], ~t.zerox_rec, \addAfter);
			};

		};
        ev.part.postln;
		switch(ev.part,
			1, {
				var delays = 2;
				~t.zerox_env = { Out.kr(~t.zerox_envbus, Line.kr(1, 2, partDur)) }.play(target:~t.preGroup);

				createDelays.value(2, \zerox_play, 1);
				~t.zerox_play.do { |x|
                    x.map(\maxDelay, ~t.zerox_envbus);
					x.set(\releaseTime, 10)
				};
				~t.tmpFork = fork {
					(~data.part[1][1] - 10).wait;
					~t.zerox_play.do(_.release);
				}

			},
			2, {
				~t.tmpFork.stop;
				~t.zerox_play.free;
				~t.zerox_env.free;
			},
            3, {
                //Temporary synth
                ~t.synth1 = {
                    var snd = In.ar(0, 2);
                    var bp = 0;
                    var freqs = [605, 662, 796, 900, 495].scramble;
                    var target = 376;
                    //Durations for envelope
                    var times = [~data.part[ev.part][1], 38];
                    /*freqs.do { |fq|
                    var d = 0.01.rrand(1);
                    bp = bp + AllpassN.ar(BPF.ar(snd.neg, fq, 0.1), d, d, 10);
                    };
                    */
                    /*
                    bp = Klank.ar(`[freqs, [0.01, 0.01, 0.015, 0.005], 1], snd) * 0.2;
                    bp = FreqShiftAA.ar(bp, Line.ar(0, -200, 20));
                    5.do { bp = AllpassN.ar(bp, 1, 0.1.rrand(1), 1) };
                    */
                    bp = freqs.collect { |fq, i|
                        var t = target + (0.1.rand2 * target);
                        var fqenv = EnvGen.kr(Env([fq, fq, target], times, \exp));
                        var out = Resonz.ar(snd, fqenv, 0.002);
                        var dly = 1.rrand(2.0);
                        var mul = i % 2 * 2 - 1; //-1, 1, -1...
                        out = Fdef(\stereo2ms).value(out);
                        out[0] = out[0] * 0.6;
                        out = Fdef(\ms2stereo).value(*out) * 2;
                        out = out - FreqShiftAA.ar(out, fq);
                        //TODO: feedback loop!
                        out + AllpassC.ar(out, dly, dly, 4.rrand(15.0), 1.5)
                    };

                    Out.ar(0, Splay.ar(bp.flat) * 3);

                }.play(target:~t.postGroup);
            },
		4, {
				~t.synth1.free; //FIXME
				~t.zerox_env.free; //FIXME
				createDelays.value(24, \zerox_play, -48.dbamp);

				~t.zerox_play.do(_.set(\maxDelay, 0.2));
				~t.zerox_env = { Out.kr(~t.zerox_envbus, XLine.kr(-36.dbamp, -12.dbamp, partDur-26)) }.play(target:~t.preGroup);
				~t.zerox_play.do(_.map(\amp, ~t.zerox_envbus));

		});

        0
    }
));

//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(Pseries(0));


)

/*EOF*/

~buf = Buffer.read(s, "songs/11*".resolveRelative.pathMatch[0])

(
//## TODO ##
//- mät upp formdelar
//- formdelar => nya presets/*defs
//- Vissa delar kan ev behöva loopas. Hur?
//- Kolla klick i första delen
Ndef(\aptest, { arg feedback = 0.0;
    var snd = PlayBuf.ar(2, ~buf, 1);
    var input = snd;

    //Delay. Line.ar have slightly longer dur
    // input = DelayC.ar(input, 10, (LFNoise2.ar(0.1).range(0,10) * Line.ar(dur:10.5)).poll);
    // input = FreqShiftAA.ar(input, {LFNoise2.kr(0.01).range(-1000, -4000)}.dup);

    // input = FreqShiftAA.ar(input, {LFNoise2.kr(10).range(-3000, -3100)}.dup(1));
    // (31..45).nthPrime.do { |f| input = AllpassC.ar(input, 0.1, f.reciprocal.postln, 0.1.rrand(20)) };


    (snd * 0.05) + input;
    input

}).play

)

