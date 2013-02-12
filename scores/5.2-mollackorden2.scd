(
~song = \snickargladje;
"lib/init.scd".loadRelative
)


//-----Song starts here------
(
var x = Prout( { |ev| var f;
    loop {
        f = [1,2,3,5,8,13].scramble.keep(ev.n).normalizeSum;
        // ev.n.postln;
        f.do { arg x;
            ev = (ev[\durMult] = x).yield;

        }
    }
});
    // var btn = NumberBox().alwaysOnTop_(true).onClose_( { CmdPeriod.run } ).front;
var p = Pchain(
    Pbind(\instrument, \klanky,
        \lag, Pwhite(-0.02, 0.07),
        \bufnum, Pfuncn({ q.buf.hits.choose}, inf),
        \legato, Phprand(0.7, 2),
        \note, Pif(Pkey(\count) < 15,
            1,
            Pif(Pkey(\count) < 26,
                Pn(1,1).stutter(Pkey(\n)/2).trace
                ++ P3n1(Pn(Pshuf((1, 3..11))), 1).wrap(-7, 11),
                2)),
        \rout, x,
        \dur, Pif (Pkey(\count) > 29, Pwhite(1,0,2), (Pkey(\dur) * Pkey(\durMult))),
    ),
    Prout({ arg ev;
        var c, count=0, ptn = Pbind(*q.data.ampdur).asStream;
        loop {
            var i = 2.rrand(5);
                // {btn.value_(count)}.defer;
            if (count > 29) {i = 1};
            c = ptn.next((n: i, count: count));
            i.do { c.yield };
            count = count + 1;

        }
    })
);

var m = (start:32, mid:2@12, end:4@00);

    // CmdPeriod.add({btn.close});

(Ppar([p, Pbind(\root, -10) <> p]) ++ Rest(10)).reap(m.end).play
// Ppar([p, p <> Pbind(\root, -10)]).reap(2@02, -0.1).play
)
