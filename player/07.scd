//# Song 07 ###

//This is (and should be) a more sound-oriented thing
//Even though (or just because) the original track has a strong dramaturgy i could imagine
//splitting it up a bit.

//The material is quite drone-y, so it's easy to jump and crossfade. This could be useful for the final
//structure of the piece -- it could be quite far from the original (and random), and still have a logic

//I have tried to create a feedback-based synth that could mix well with the bass,
//but haven't really succeeded.

//The following is a few tryouts and fragments.

~buf = Buffer.read(s,"songs/07-20160316-1539.wav".resolveRelative )
~buf = Buffer.read(s, "songs/07-20160813-1254.wav".resolveRelative )

(
var from = 300;//q.player.data.phrase.last;
var to = 400;//from.sum;
// from = from[0];

//## Test 1 ##

//Segmentation & randomization of last part
Pdef(\sdf, Pbind(
    \instrument, \bufSegmentFreqshift,
    \dur, Prout({ |ev|

		//This splits the part (from..to) into random-sized segments (between 3 and 7)
        var positions = Fdef(\randomSegments).(from, to, 3.0, 7.0);
        var durations = (positions ++ to).differentiate[1..];
        var order = Array.series(positions.size).scramble;
        order.do { |index|
            ev.startPos = positions[index];
            ev = durations[index].yield;
        }

    }),
    \bufrate, 1,
    //TODO: freqshift shifts, reasonable weights, reasonable frequencies
    \freqshift, Pwrand([0, -98], [0.9, 0.1], inf),
    \amp, Pwhite(0.1, 1),
    \bufnum, ~buf,
    \legato, Pn(2, inf),
    \fadetime, 5
).repeat(inf)).play;
)

Pdef(\sdf).fadeTime = 10
Pdef(\sdf).stop
//## Test 2 ##

//Granulated and freqshifted
(
var start = 300;
Pdef(\test07,
    Pbindf(
        Pspawner({ |sp|
            loop {
                var totDur = 1.0.rrand(30);
                "spawn".postln;
                sp.par(
                    Plazy({
                        var dur = 0.01.rrand(0.05);
                        var freqShift = -800;
                        var start = 300.rrand(350);
                        Pbind(
                            \instrument, \bufSegmentFreqshiftMS,
                            \bufnum, ~buf,
                            \dur, dur,
                            \legato, 3,
                            \startPos, Ptime() + Pwhite(-0.1, 0.1) + start + Pn(Pseries(0, 1, Pwhite(2, 16).asStream)),
                            \bufRate, Pwhite(0.99, 1.00),
                            //removing some mid from the signal to make it less focused
                            \freqshift, freqShift,
                            \amp, Pseg([0.01,2, 0.01], totDur * 0.5, \exp),
                            \fadetime, 0.01
                        )
                    })
                );
                (totDur * 0.5).wait;
            }
        }),
        \midAmp, Pseg(Pwhite(-12, 0), Pwhite(4, 8.0), \lin).dbamp,
        \sideAmp, Pseg(Pwhite(0, 9), Pwhite(4, 8.0), \lin).dbamp,


    )
).play;
)
Pdef(\test07).stop

//## Test 3 ##

//Feedback drone controlled by buffer amp
(
Ndef(\fbfb, {
	var buf = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf), startPos:44100*20);
	//parallel buffer playback
	var buf2 = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf) * 1, startPos:44100*300);
	var dur = ~buf.duration;
	var snd;
	var bufamp = Amplitude.ar(buf.sum, 0.1, 1);

	//Feedback loops
	snd = (1.088 * [55, 110, 165, 220, 330]).collect { |fq|
		var sn2, fb = FbNode(1, 0.05, 0);
		var amp = Amplitude.ar(fb, 0.1, 1);

		sn2 =(fb * 1) + buf.sum;
		fb.delay(LFDNoise3.ar(amp.lag(2)).range(110, 880).reciprocal);

		sn2 = LPF.ar(sn2.distort, LFNoise2.ar(0.3).exprange(500,12000));
		sn2 = CombN.ar(sn2, 0.05, (fq * LFNoise2.ar(0.13).range(0.99,1.02)).reciprocal, 4, (1 - amp.lagud(0.1, 0.5)).clip(0, 1));

		//Add Impulse, to get some rhythm into the mix
        sn2 = LeakDC.ar(sn2);//  + RLPF.ar(Impulse.ar(10, 0, LFNoise2.kr(2).exprange(0.5, 4)), 5876, 0.05);
		fb.write(sn2);

	};

	snd = Splay.ar(snd);

	//Add freqshift
	snd = snd + FreqShift.ar(snd, Fdef(\autoscale).(bufamp * PinkNoise.ar(0.1), 410, Line.ar(420, 880, dur), inf, -inf, \ar));
    // snd = AllpassN.ar(snd, 0.1, LFNoise2.ar(0.1).range(0.04, 0.06), 5);

	snd = snd;

    // buf = buf + CombC.ar(buf, 8, 8, 8, 0.3);

    Line.ar(0, 75, dur:75, doneAction:2).poll;

    (buf + (snd * 0.1 * bufamp.lag(10))) * 4 + FreqShiftAA.ar(buf2, -4000, 0, 0.1);
}).play
)
Ndef(\fbfb).fadeTime = 0;
Ndef(\fbfb).clear
NdefGui(Ndef(\fbfb))

//## Test 4 ##

(
"lib/init".import;
q.player.actionLabels = #[phrase, part];
q.player.tickLabel = \phrase;
q.player.loadData("07");
//q.player.extractFeatures;
q.playerui.connect(q.player);

q.player.onReady = {

	~t.comb = Synth(\feedback_07, [\amp, -40.dbamp], target: ~t.postGroup)

};

q.player.actions.part.onStart = { |ev, part|
	q.playerui.log(part, "Part");
	switch(part,
		1, {
			~t.rout = fork {
				11.5.wait; //Wait for first pizz
				s.bind {
					//Continue feedback loop without support from bass
					~t.comb.set(\inAmp, 0);
					~t.comb.set(\minFeedback, -5);
					~t.comb.set(\ampAutoscale, 0.9);

				}
			}
		},
		2, {
			~t.rout.stop; //Stop previous routine (if still active)
			s.bind {
				"hello part 3".postln;
				~t.envBus = Bus.control(s);
				~t.env = { Out.kr(~t.envBus, EnvGen.kr(Env([0.9, 0.1], [60]))); }.play(target:~t.preGroup);
				~t.comb.map(\ampAutoscale, ~t.envBus);
				~t.comb.set(\partials, 102 * (1..8));
			}
	});
};

q.player.setPtn(Pbind(
	//This is good -- first part should have overlapping segments
	\fadetime, 5,

	\combSetFunc, p { |ev|
		var target = ~data.firstPartRepeat;
		// var targetVal = -0.
		var leakCurve = Pseg2([0,0.6], target+1, 4).asStream;
		var fbCurve = Pseg2([2.9, 9], target+1, 4).asStream;
		// var lfbCurve = Pseg2([0.59, -9], target+1, -4).asStream;
		var stretch = Pseries(1, 0.001).asStream;
		var freqs = #[81,102,242,404] *.x [1,2];


		loop {
			//Only set if not nil (assuming all streams have equal length)
			leakCurve.next !? { arg leak;
				s.bind {
					~t.comb.set(\partials, freqs * Array.geom(8, 1, stretch.next));
					~t.comb.set(\leak, leak);
					~t.comb.set(\maxFeedback, fbCurve.next);
					// ~t.comb.set(\minFeedback, lfbCurve.next);

				};
			};

			ev = 0.yield;
		};
	}

));

// q.player.setIterator(Pn(q.player.data.phrase.size - 1, 1))

//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(
    Plazy({
        var part = ~data.lookup.part;
        var repeatFirst = 1;//4.rrand(8);
		~data.firstPartRepeat = repeatFirst;
        Pseq([
			Pxrand(Array.series(part[1]-1, 0), repeatFirst),
			Pseries(part[1]),
        ])
    })
);
)



q.player.play
q.player.stop
q.player.readyForPlay

x = fork { 10.do { "hello".postln; 1.wait }}

x.stop


(
//Synthesizer
Pdef(\gloglo, Pbind(
    \instrument, \fmGloss,
    \dur, 2,
    \legato, 4,
    \root, 7,
    \octave, 3,
    \ctranspose, 0.25,
    \scale, Prand([Scale.dorian, Scale.mixolydian], inf),
    \amp, Pwhite(0.05, 0.8),
    \out, 0,
    \detune, -10,
    // \timingOffset, Pwhite(0.0, 0.05),
    // \strum, Pwhite(0.0, 0.1),
    \degree, 0 ,
    // \degree, 0
)).play
)
Pdef(\gloglo).stop

//Sine waves for beatings
(
Ndef(\sino, { SinOsc.ar(SinOsc.kr(0.02).range(94, 97.99)) * 0.05.dup }).mold.play;
Ndef(\sino3, { SinOsc.ar(SinOsc.kr(0.02).range(94, 97.99 ) * 1.5) * 0.009.dup }).mold.play;
Ndef(\sino2, { SinOsc.ar(SinOsc.kr(0.02).range(94, 97.990001) * 2) * 0.01.dup }).mold.play;
)

Ndef(\sino2).fadeTime = 10;
Ndef(\sino).fadeTime = 10;
Ndef(\sino).end; Ndef(\sino2).end; Ndef(\sino3).end

//Freq shift to lose root note
Ndef(\fqshift, { arg gate=1; var snd = In.ar(0, 2); var env = EnvGen.kr(Env.asr, gate, doneAction:2); ReplaceOut.ar(0, (env * FreqShiftAA.ar(snd, Line.ar(-1000, -10000, 30))) + ((1 - env) * snd)) }).play(addAction:\addToTail);

//test-08-magsmooth is also good

Ndef(\fqshift).set(\gate,0)
Ndef(\fqshift).fadeTime = 10
Ndef(\fqshift).end