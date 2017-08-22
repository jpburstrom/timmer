"lib/init".import;
q.player.actionLabels = #[start];
q.player.tickLabel = \start;
q.player.loadData("07");

q.player.onReady = {
    var compLookahead = 0.01;
    var revSize = 2;

    ~t.softclip = Synth(\softclip,
        [\outbus, ~t.fxOut, \pregain, 8, \amp, 0.1],
        ~t.postGroup, \addToTail);
    ~t.compressor = Synth(\compressor,
        [\outbus, ~t.fxOut, \thresh, 0.5, \ratio, 8, \attack, compLookahead, \release, 0.05, \amp, 1],
        ~t.postGroup, \addToTail);
    //zap bad values before sending to verb
    ~t.zapper = Synth(\zapper, nil, ~t.postGroup, \addToTail);

    //SEND FX
    ~t.verb = Synth(\jpverb,
        [\inbus, ~t.fxOut, \outbus, ~t.fxOut, \time, 1, \amp, 0.7, \damp, 0.4, \size, 0.3],
        ~t.sendGroup, \addToTail);

    //FIX FX LATENCY
    ~t.latencyFix = Synth(\fixedDelay,
        [\outbus, ~t.mainOut, \maxDelay, compLookahead, \delay, compLookahead],
        ~t.sendGroup, \addToTail);
};
q.player.setPtn(
    Plazy {
        var segSeq = Pseq(([0, 1] - 0.6.rrand(0.8)).abs);
        Pmono(\meckamack_07,
            //FIXME: Noise volume
            //2 channel output
            \fxout, Pfunc { ~t.fxOut },
            \noiseMix, Pseg(Pwhite(0.0, 1), 30) * (Ptime() * 0.05).min(1),
            \totalDur, Plazy { Pn(~soundFile.duration) },
            \noiseDelay, (Pseg([0, 0, 1, 1], [10, 5, inf]) * Pwhite(0, 1.0) * Pseg([0.0001,1,0.0001], segSeq * Pkey(\totalDur), \exp)).trace,
            \noiseDelayLag, Pwhite(0, 0.02),
            \freqshift, Pseg(Pwhite(-1000, 0), Pwhite(0.1, 10)),
            \rate, Pwhite(0.999, 1.001),
            \freq, Pseg(Pexprand(80, 600), 10),
            \dur, Pwhite(1.0, 2.0) * Pseg([1, 0.01, 0.5], segSeq * Pkey(\totalDur), \exp),
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

q.player.t.verb.set(\size, 3)
q.player.t.verb.set(\time, 0.1)
q.player.t.verb.set(\amp, 0.7)
q.player.t.softclip.set(\pregain, 8)