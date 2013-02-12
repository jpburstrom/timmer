
q.make({
    "Loading server stuff".postln;

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
        (
            snickargladje: {
                ~hits = SoundFile.collectIntoBuffers( q.path.samples +/+ "banks/hits/*");
            }

        ).at(q.song).value



    }, \boot);



    //Server Groups
    ~grp = Setup({
        //"Give me a group".postln;
        ~test = Group(s);
        ~test2 = Group(s, \addToTail);
        ~foo = Group(~test2);

    }, \tree);


    //Synths (Always-running fx)
    ~synth = Setup({
        // p.grp.test.postln;
    });

});