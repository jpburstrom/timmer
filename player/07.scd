//# Song 07 ###

//This is (and should be) a more sound-oriented thing
//Even though (or just because) the original track has a strong dramaturgy i could imagine
//splitting it up a bit.

//The material is quite drone-y, so it's easy to jump and crossfade. This could be useful for the final
//structure of the piece -- it could be quite far from the original (and random), and still have a logic

//I have tried to create a feedback-based synth that could mix well with the bass,
//but haven't really succeeded.

//The following is a few tryouts and fragments.

(
"lib/init".import;
~buf = Buffer.read(s, "../player/songs/07*".resolveRelative.pathMatch.reverse[0] );
~claps = "../player/samples/handclaps/*.wav".resolveRelative.pathMatch.collect (Buffer.read(s, _ ));
)


(
value {
var from = 300;//q.player.data.phrase.last;
var to = 400;//from.sum;
var dur = 60*5; //unused?
//Moving from freqshifted to plain
Pdef(\sdf, Pbind(
    \instrument, \bufSegmentFreqshiftMS,
    \freqshift, 0,
    \minSize, 3,
    \maxSize, Pkey(\minSize) * 2.5,
    \dur, Prout({ |ev|

        loop {
            //This splits the part (from..to) into random-sized segments (between 3 and 7)
            var positions = Fdef(\randomSegments).(from, to, ev.minSize, ev.maxSize);
            var durations = (positions ++ to).differentiate[1..];
            var order = Array.series(positions.size).scramble;
            order.do { |index|
                ev.startPos = positions[index];
                ev = durations[index].yield;
            }
        }

    }),
    \bufnum, ~buf,
    \midAmp, Pwhite(-12, 0).dbamp,
    \legato, Pbrown(1.0, 2.0),
    \amp, Plprand(0.02, 0.5),
    //Problem: boring fades
    \pan, Pfuncn({ 0.7.bilinrand }, inf),
    \fadetime, Pwrand([Pfuncn { "click".postln; 0.002 }, Pwhite(4.0, 5.0, 1)], [0.01, 0.99], inf);
));
};

//Static radio noise thing
Ndef(\meckamack_07, {
    var snd = PlayBuf.ar(2, ~buf, 1, Impulse.kr(100),
        startPos:Phasor.ar(Dust.ar(1), SampleRate.ir.reciprocal * LFNoise1.kr(0.2).range(0, 0.2), 300, 500, Stepper.ar(Impulse.ar(0.1), 300, 300, 400))*BufSampleRate.kr(~buf));
    // var snd = BufRd.ar(2, ~buf, LFNoise1.ar(LFNoise1.ar(0.1).range(0.001, 0.003)).range(300, 400).poll * BufSampleRate.kr(~buf));
    var impchain, chain = FFT({LocalBuf(16384)}.dup, snd);
    var noise = LFNoise0.ar(LFNoise0.kr(0.5).range(0.1,1)).range(0.001, 0.1);
    var imp = Splay.ar({ |i| BPF.ar(WhiteNoise.ar(1), (i*LFNoise1.kr(0.2).range(96,100)) + 400, noise) }.dup(10).scramble);

    // imp = (imp * 0.6) + (imp.reverse * 0.4);

    impchain = FFT({LocalBuf(16384)}.dup, imp);

    chain = PV_CopyPhase(impchain, chain);
    // chain = PV_MagSmooth(chain, 0.4);
    imp = IFFT(chain) * snd * 20;

    // snd
    LPF.ar(imp * 0.007, LFNoise2.ar(0.3).exprange(1000, 10000)); //(snd * 10).distort * 0.1
    // snd.dup
});

value {
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
    );
};

//Feedback drone controlled by buffer amp
Ndef(\fbfb, {
	var buf = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf), startPos:44100*20);
	//parallel buffer playback
	var buf2 = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf) * 1, startPos:44100*300);
	var dur = ~buf.duration;
	var snd;
	var bufamp = Amplitude.ar(buf.sum, 0.1, 1);

	//Feedback loops
    // snd = (1.088 * [55, 110, 165, 220, 330]).collect { |fq|
    snd = (1.088 * 5.collect { 55.rrand(330) }).collect { |fq|
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

    snd = HPF.ar(((buf + (snd * 0.01 * bufamp.lag(10))) * 4 + FreqShiftAA.ar(buf2, -4000, 0, 0.1)), 5);

    snd = snd * EnvGen.ar(Env([0.0,1,1,0], [3, 64, 8], [-4, 0, 4]), doneAction:2) * 0.3;

});

//Synthesizer
Pdef(\gloglo, Pbind(
    //TODO: change instrument
    \instrument, \fmGloss,
    \dur, Pbrown(0.01, 0.2, 0.009),
    \sustain, Pseq([0.01, 0.02, 0.03], inf),
    \freq, Pseg(Pwhite(40, 80), 10),
    \amp, Pbrown(0.1, 0.3, 0.01) * Pseg([1, 0.0001], 100, \exp) * 0.1,
    \out, 0,
    // \timingOffset, Pwhite(0.0, 0.05),
    // \strum, Pwhite(0.0, 0.1),
    // \degree, 0
));

Pdef(\claps, Pbind(
    \instrument, \bufSegmentFreqshiftMS,
    \freqshift, Pwhite(-500, -10000),
    \midAmp, Pwhite(0.1, 1),
    \sideAmp, Pwhite(0.1, 1),
    \bufnum, Pseq(~claps, inf),
    \dur, Pwhite(0.01, 0.06) * Pseg(Pwhite(1.0, 10.0), Pwhite(1.0, 20.0)),
    \sustain, 0.5,
    \amp, Pseg([1, 0.01, 0], Pseq([10, Pwhite(10, 30, 1)], inf), Pseq([\exp, \lin], inf), inf) * 0.4
));


)


(
////////
//SONG//
////////
var freqs = \G1.namecps * ((-1..-100) ++ (1..10));
Pdef(\sdf10, Pspawner({ |sp|
    var st = ();
    var it = 8;
    var type = \note;

    var durs = Pgeom(15, 0.9, it).integrate.asStream - 15;
    it.do {
        sp.par(Pbindf(Pdef(\sdf),
            //Route two signals,
            \amp, Ptuple([Pkey(\amp), 0.5 - Pkey(\amp)]) * 0.7,
            \out, [0, 2],
            \type, Pfunc { type },
            \dur, Pkey(\dur) * Pseg([1, 0.7, 1], 30, repeats:inf),
            // \fadetime, Pkey(\fadetime) * Pseg([1, 0.1, 1], 30, repeats:inf),
            //TODO: multiply w/ Pseg long-form
            \freqshift, Pxrand(freqs, inf) * Pseg([1, 0, 1], 30, repeats:inf) * Pseg([0, 1, 1, 0], Pseq([30, 150, 60])),
        ), durs.next);
    };
    // sp.wait(45);
    // Ndef(\fbfb).end;
    sp.wait(200);
    Ndef(\meckamack_07).play;
    sp.wait(100);
    "Ndef comes here".postln;
    Ndef(\fbfb).play;
    type = \rest;
    sp.wait(10.rrand(20));
    type = \note;

    sp.suspendAll;
    st.claps = sp.par(Pdef(\claps), 0.0.rrand(3));
    st.glo = sp.par(Pdef(\gloglo), 0.0.rrand(3));
    st.test07 = sp.par(Pdef(\test07), 0.0.rrand(3));

    5.rrand(20).wait;
    // sp.suspendAll; //TODO fade/wait for next, especially \test_07 is a bit harsh...


    Ndef(\fbfb).play ; //bug: doesn't play

    //Finish off a bit randomly
    st.values.scramble.do { |stream|
        2.0.rand.wait;
        sp.suspend(stream);
    };
    //Fade out last
    Ndef(\meckamack_07).fadeTime = 20;
    Ndef(\meckamack_07).end;

    //wait for \fbfb to stop

})).play
)




//--sketches--

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


//Sine waves for beatings
(
Ndef(\sino, { SinOsc.ar(SinOsc.kr(0.02).range(94, 97.99)) * 0.005.dup }).mold.play;
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