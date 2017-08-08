"lib/init".import;
q.player.actionLabels = #[start];
q.player.tickLabel = \start;
q.player.loadData("07");
q.player.channels = 2; //

q.player.setPtn(
    Plazy {
        var segSeq = Pseq(([0, 1] - 0.6.rrand(0.8)).abs);
        Pmono(\meckamack_07,
            //FIXME: Noise volume
            //2 channel output
            \outbus, 0,
            \noiseMix, Pseg(Pwhite(0.0, 1), 30) * (Ptime() * 0.05).min(1),
            \totalDur, Plazy { Pn(~soundFile.duration) },
            \noiseDelay, Pwhite(0, 1.0) * Pseg([0.0001,1,0.0001], segSeq * Pkey(\totalDur), \exp),
            \noiseDelayLag, Pwhite(0, 0.02),
            \freqshift, Pseg(Pwhite(-1000, 0), Pwhite(0.1, 10)),
            \rate, Pwhite(0.999, 1.001),
            \freq, Pseg(Pexprand(80, 600), 10),
            \dur, Pwhite(1.0, 2.0) * Pseg([1, 0.01, 0.5], segSeq * Pkey(\totalDur).trace, \exp),
            // \delta, Pseq([0, Pn(Pkey(\dur))]),
            \fadetime, 0.02,

        )
    }
);

q.player.setIterator(Pn(0));
// q.player.trace = false

/*EOF*/

q.player.data.score
q.player.modPtn.asCompileString

q.player.play
Server.default = Server.local

s