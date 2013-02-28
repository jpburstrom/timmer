
q.make({
    "Loading server stuff".postln;

    //Buses
    q.makeSetup(\bus, {

        //Jack outputs
        ~out1 = Bus(\audio, 0);
        ~out2 = Bus(\audio, 2);
        ~out3 = Bus(\audio, 4);
        ~out4 = Bus(\audio, 6);

        //Other useful buses
        ~in1L = Bus.audio(s, 1); // mono busses
        ~in1R = Bus.audio(s, 1);
        ~in1 = Bus.audio(s, 2); //Stereo busses
        ~in2 = Bus.audio(s, 2);
        ~in3 = Bus.audio(s, 2);
        ~in4 = Bus.audio(s, 2);

        //From analysis group (should be removed)
        // ~onsets = Bus.control(s, 1);
        // ~amplitude = Bus.control(s, 1);
        // ~pitch = Bus.control(s, 1);


    }, \boot);



    //Buffers
    q.makeSetup(\buf, {
        q.smpLoad('banks/hits');
        (
            snickargladje: {
                q.smpLoad('banks/hits');
            }

        ).at(q.song).value


    }, \boot);



    //Server Groups
    q.makeSetup(\grp, {
        //We set up 5 main buses
        [\in, \ctl, \syn, \ins, \fx].do { arg sym;
            currentEnvironment[sym] = Group.tail;
        };


    }, \tree);

    //Controls (
    q.makeSetup(\ins, {

    }, \tree);

    q.makeSetup(\fx, {

    }, \tree);

    //Controls (
    q.makeSetup(\ctl, {
        // "CONTROL".postln;
    }, \tree);

});