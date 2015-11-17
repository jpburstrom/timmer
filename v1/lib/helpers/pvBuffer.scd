//Generate buffer to play with PV_*Buf UGens
(
{
    arg path = "/Volumes/Mega/projects/timmer/render/to SC/looptest.wav";
    var duration, pvPath,
    frameSize = 8192,
    hopSize = 0.25;

    pvPath = path ++ "." ++ frameSize ++ ".scpv";

    if (File.exists(pvPath).not) {
        //Our NRT Synthdef
        SynthDef("timmer-pvrec", { arg recBuf=1, soundBufnum=2;
            var in, chain, bufnum;
            Line.kr(1, 1, BufDur.kr(soundBufnum), doneAction: 2);
            in = PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum), loop: 0);
            bufnum = LocalBuf.new(\frameSize.ir, 1); // uses frame size from above
            // note the window type and overlaps... this is important for resynth parameters
            chain = FFT(bufnum, in, \hopSize.ir, 1);
            chain = PV_RecordBuf(chain, recBuf, 0, 1, 0, \hopSize.ir, 1);
            // no ouput ... simply save the analysis to recBuf
        }).add;

        duration = SoundFile.use(path, { |f| f.duration });
        ScoreClock.beginScore;
        Routine {
            var src, recbuf;

            src = Buffer.read(Server.default, path);
            recbuf = Buffer.alloc(Server.default, duration.calcPVRecSize(frameSize, hopSize, 48000));
            0.01.wait;
            Synth('timmer-pvrec', [\recBuf, recbuf, \soundBufnum, src, \frameSize, frameSize, \hopSize, hopSize]);

            duration.yield;

            recbuf.write(pvPath, "wav", "float32");
            0.99.yield;

            [src, recbuf].do(_.free);

        }.play(ScoreClock);

        ScoreClock.makeScore(duration + 1).render("/tmp/timmerpvrender", duration + 1);


    };

}.value

)
