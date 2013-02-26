SynthDef(\sineTest, { Out.ar(0, SinOsc.ar(\freq.kr, 0, \amp.kr) * EnvGen.ar(Env.perc(0.001, \sustain.kr, curve:0), doneAction:2) !2) }).add;

(
l= RedLSystem("F", ($F: "F[-F]F[+F]F"));
2.do{l.next};
RedLTurtle(l, 40, 25, 0.65, 0.1).makeWindow(initTranslate: Point(0.5, 0));
)

(
e = ().make {~dur = 0.01; ~octave = 1; ~level = 0;} ;
Penvir(e,
    Pbind(
        \ptn, Prewrite(Pn("F", 1), ($F: "F[-F]F[+F]F", $G: "GF"), 6),
        \rules, Pfuncn({ arg ev;
            // ev.re.postln;
            switch(ev.ptn,
                $F, {  ev.dur = max(0.5 * ~octave, 0.01) },
                // $G, { ~dur = ~dur * 1.01; ev.dur = 0; ev.type = \rest  },
                // $L, { ~level = ~level + 1; ev.dur = 0; ev.type = \rest  },
                $+, { ~dur = ~dur * 1.2; ev.dur = 0; ev.type = \rest },
                $-, { ~dur = ~dur / 1.2; ev.dur = 0; ev.type = \rest },
                $], { ~level = ~level - 1; ~octave = ~octave * (1.4); ev.dur = 0; ev.type = \rest },
                $[, { ~level = ~level + 1; ~octave = ~octave / (1.4); ev.dur = 0; ev.type = \rest }
            );
            1
        }, inf),
        // \hell0, Pn(Pn(1, 10) ++ Rest()),
        \level, Pfuncn({ ~level }, inf),
        // \octave, Pfuncn({ ~octave }, inf),
        \amp, Pn(Pfin(10, 0.2) ++ Pn(0.05, 1)),
        \octave, 3,
        // \harmonic, Pfuncn({ ~level + 5}, inf),
        \degree, Pfuncn({ (~dur * ~level) + [-2,2,7] }, inf),
        \instrument, \sineTest,
        \legato, 2
)).play

)
Pattern


p = Proto ({
    ~dur = 0.1;
    ~octave = 5;
    ~level
    ~asPattern = {
        Pbind(
            \ptn, Prewrite(Pn("F", 1), ($F: "F+F-[F-F]+FG", $G: "GF"), 4),
            \rules, Pfuncn({ arg ev;
                // ev.re.postln;
                switch(ev.ptn,
                    $F, { ev.dur = 0.015 * ~octave },
                    $G, { ~dur = ~dur * 1.01; ev.dur = 0; ev.type = \rest  },
                    $+, { ~dur = ~dur * 1.8; ev.dur = 0; ev.type = \rest },
                    $-, { ~dur = ~dur / 1.8; ev.dur = 0; ev.type = \rest },
                    $], { ~octave = ~octave - 0.3; ev.dur = 0; ev.type = \rest },
                    $[, { ~octave = ~octave + 0.3; ev.dur = 0; ev.type = \rest }
                );
                1
            }, inf),
            \octave, Pfuncn({ ~octave }, inf),
            \amp, ~dur,
            \degree, Pfuncn({ ~dur }, inf).round,
            \instrument, \sineTest
        )
    }
}) => PR(\test)
BP(\test).free
PR(\test) => BP(\test)
BP(\test).play

p.asPattern

PR
