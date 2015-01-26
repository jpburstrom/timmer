q.make {

    ~tree = Setup(nil, \tree).on(\build, {
        "Adding groups".postln;
        ~syngrp = Group();
        \groups
    });

    ~bus = Setup({
        "Adding buses".postln;
        s.makeBundle(0.1, {
            ~test = Bus.audio();
        });

    }, \boot);



}
