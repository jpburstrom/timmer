q.make {

    ~tree = Setup(nil, \tree).on(\build, {
        "Adding groups".postln;
        s.makeBundle(nil, {

            //Group for synths
            ~syngrp = Group().register;
            //LFOs and other controls, before synths
            ~ctlgrp = Group.before(~syngrp).register;
            //Analysis, before controls
            ~anagrp = Group.before(~ctlgrp).register;

            //Master fx, last
            ~mstfxgrp = Group.after(~syngrp).register;

        });
        s.sync;
        \groups
    });

    ~bus = Setup({
        "Adding buses".postln;

        //s.newBusAllocators; //BIG HACK

        s.makeBundle(0.1, {
            ~bass = Bus(\audio, 0);
        });

    }, \boot);

}