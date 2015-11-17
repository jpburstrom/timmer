(
~song = \mellanljuden;
"lib/init.scd".loadRelative;

MIDIIn.connectAll
)




b = Wavesets.from(q.find(\samples, "test/mellanljuden-excerpt.wav"))
	Wavesets.prepareSynthDefs;

(

p.pattern =    Pbind(
    \num, (p { var x = 0.rrand(10); loop { x.yield }  } + Pseries(0, 0.1)).wrap(0, b.numXings),
    \repeats, Pgeom(1, 1.4).round,
            \rout, Pfuncn({ |ev|

                // ev.postln;

                // ev.merge(b.eventFor(ev.num, 20, 1, 1));
                b.eventFor(ev.num.asInteger, ev.repeats, 1, 1).keysValuesDo { arg k, v;
                    ev[k] = v;
                };

                1


            }, inf),
            \dur, Pkey(\sustain),
            \amp, 1,
    \pan, Pwhite(-1, 1)

            //\count, Pn(1, 30)
        );

)

MIDIPlayer

(

p = Proto( {

    ~voices = ();

    ~pattern = Pbind();

    MIDIdef.noteOn(\ptnOn, e { arg amp, note; ~voices[note].stop; ~voices[note] = ~pattern.play });
    MIDIdef.noteOff(\ptnOff, e { arg amp, note; ~voices[note] = ~voices[note].stop });

})


)
Pgeom(1, 1.4).asStream.nextN(10).round



{ Stepper.kr(SinOsc.kr(1) < 0).poll }.play


BBCut2
AnalyseEvents2


Quarks.gui

TransportWindow
w = TransportWindow();

