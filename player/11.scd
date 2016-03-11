~buf = Buffer.read(s, "/Volumes/HD2/projects/timmer-2015/render/11-Bivax stråk ___-44100.wav")

//## Initialize ###
(
"lib/init".import;
q.player.actionLabels = #[part];
q.player.tickLabel = \part;
q.player.loadData("11");
//q.player.extractFeatures;
q.playerui.connect(q.player);
)
q.player.play(1)
q.player.stop
q.player.data.score.do(_.postln); nil
q.player.currentEvent
q.player.reset; q.player.asPattern(1).asStream.nextN(10, ()).do(_.postln);nil;
(
//## Patterns #######

//This sets a pattern used to modify the base player pattern.
q.player.setPtn(Pbind(
    \dummy, Pfunc { |ev|
        switch(ev.part,
            1, {
                //Scramble & granulate
                //WIP
                ~t.dly = {
                    var trig = Dust.ar(100);
                    var rand = TRand.ar(0, 10.0, trig);
                    var dly1, dly2, fade,
                    snd = In.ar(0,2);

                    dly1 = Latch.kr(rand, PulseDivider.kr(trig, 2, 0));
                    dly2 = Latch.kr(rand, PulseDivider.kr(trig, 2, 1));


                    [rand].poll;
                    //-1=>1
                    fade = Stepper.ar(trig, 0, -1, 2, 2).lag(0.1);

                    snd = XFade2.ar(DelayC.ar(snd, 10, dly1), DelayC.ar(snd, 10, dly2), fade);

                    ReplaceOut.ar(0, snd);
                }.play(target:~t.postGroup);
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
        });

        0
    }
));

//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(Pseries());

//## Callbacks ####
//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar
q.player.onReady = {
    ~t.reverb = Synth(\plate_reverb_2x2, [\amp, -12.dbamp, \decay, 0.1], ~t.sendGroup);
};

)



(
//## TODO ##
//- mät upp formdelar
//- formdelar => nya presets/*defs
//- Vissa delar kan ev behöva loopas. Hur?
//- Kolla klick i första delen
Ndef(\aptest, { arg feedback = 0.0;
    var snd = PlayBuf.ar(2, ~buf);
    var input = snd;

    //Delay. Line.ar have slightly longer dur
    input = DelayC.ar(input, 10, (LFNoise2.ar(0.1).range(0,10) * Line.ar(dur:10.5)).poll);
    input = FreqShiftAA.ar(input, {LFNoise2.kr(0.01).range(-1000, -4000)}.dup);



    (31..45).nthPrime.do { |f| input = AllpassC.ar(input, 0.1, f.reciprocal.postln, 0.1.rrand(20)) };


    (snd * 0.05) + input

}).play

)

