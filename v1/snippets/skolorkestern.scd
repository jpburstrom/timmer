Pmul(\dur,
        Pseq([1, 4/5], inf).stutter(Pseq([4, 5], inf)),
        Pbind(
            \instrument, "bufKlank4Wood2",
            \hello, Pseq([1, 1, 1, 1, 1, 1, Prand([Rest(), 1])], inf),
            \bufnum, Pfunc({q.buf.at('banks/hits').choose}),
            \triggeramp, 2,
            \bufRate, Pseries(step:0.02).fold(0.8,1.2),
            \freq, Pfunc({0.rrand(500)}).stutter(60) + Prand([50, 100, [50, 240]], inf),
            \dur, 0.2,
            \legato, 3,
            \lag, Pfunc({0.rrand(0.05)}).stutter(60),
            \width, Pwhite(0, 0.5),
            \hpf, 100,
            \db, -24)
    ).play(quant:1);
    Pbind(\instrument, "bufKlank4Vibraphone", \dur, 0.5, \legato, 2, \freq, Pseq([\r, \r, 60, 40, \r], inf), \width, 0).play(quant:1);

    Pbind(\instrument, "bufKlank4Clump",
        \dur, 2.5,
        \legato, 1,
        \freq, Pseq([\r, 100, 400, \r], inf),
        \width, -0.5, \amp, 0.1, \bufnum, Pfunc({q.buf.at('banks/hits').choose})).play(quant:1)
