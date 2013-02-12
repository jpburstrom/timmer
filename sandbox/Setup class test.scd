(
q !?  { q.freeAll };
q = Setup({
    //Some common path settings here


    //

    //Buses
    ~send = Setup({

        //Jack outputs
        ~main = Bus(\audio, 0);
        ~rfx1 = Bus(\audio, 2);
        ~rfx2 = Bus(\audio, 4);
        ~rfx3 = Bus(\audio, 6);

        //Other useful buses
        ~test = Bus.audio(s, 1);

    }, \boot);

    //Buffers
    ~buf = Setup({

    }, \boot);

    //Server Groups
    ~grp = Setup({
        //"Give me a group".postln;
        ~test = Group(s);
        ~test2 = Group(s, \addToTail);
        ~foo = Group(~test2);
    }, \tree);

    //Synths (Always-running fx)
    ~synth = Setup({ |p|
        p.grp.test.postln;
    });

});
"---Wait for setup---";

//Continue setup if needed...
q.on(\build, { |ev|
    "Part 1".postln;
    ~grp.make { ~anotherGroup = Group(~test).postln };
    \part2
});

//Continue setup if needed...
q.on(\part2, { |ev|
    var c = Condition.new;
    "Part2".postln;//grp.make { ~anotherGroup = Group(ev.grp.test) }
    (Pbind(\note, Pseq([1])) ++ Pbind(\note, Pfuncn({c.test_(true).signal; \rest}))).trace.play;
    c.wait;
    \part3
});

//Continue setup if needed...
q.on(\part3, { |ev|
    "END".postln;//grp.make { ~anotherGroup = Group(ev.grp.test) }

});
"-----"
)

a = Setup({})
a.use { 2 }.postln
fork { a.use { 2 }.postln }
