q.make {

    ~tree = Setup(nil, \tree).on(\build, {
        "Adding groups".postln;
        ~syngrp = Group();
        ~ctlgrp = Group.before(~syngrp);
        ~mstfxgrp = Group.after(~syngrp);
        \groups
    });

    ~bus = Setup({
        "Adding buses".postln;
        s.makeBundle(0.1, {
            ~test = Bus.audio();
        });

    }, \boot);



}
