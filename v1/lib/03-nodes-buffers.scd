
q.make({
    "Loading server stuff".postln;

    //Buses
    q.makeSetup(\bus, {

        ~anaIn = Bus.audio(s, 1)

        //Jack outputs
        /*
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
        */


    }, \boot);



    //Buffers
    q.makeSetup(\buf, {
        ~envs = ().make {
            ~grain = ().make {
                q.envs.grain.keysValuesDo { arg label, env;
                    currentEnvironment[label] = Buffer.sendCollection(s, env.discretize);
                }
            }
        };


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

    //inputs (
    q.makeSetup(\inputs, {

        Synth(\soundIn, [\bus, 0, \outbus, q.bus.anaIn], q.grp.in);

    }, \tree);

    //FX (
    q.makeSetup(\ins, {

    }, \tree);

    q.makeSetup(\fx, {

    }, \tree);

    //Controls (
    q.makeSetup(\ctl, {
        q.makeCtl(\onsets, \anaOnsets, [\bus, q.bus.anaIn], 1);
        q.makeCtl(\pitch, \anaPitch, {[\bus, q.bus.anaIn, \trig, q.bus.ctl_onsets.asMap]}, 2);
        q.makeCtl(\amplitude, \anaAmp, {[\bus, q.bus.anaIn, \trig, q.bus.ctl_onsets.asMap]});
        q.makeCtl(\spectral, \anaSpectral,
            {[\bus, q.bus.anaIn, \trig, q.bus.ctl_onsets.asMap]}, 2);

    }, \tree);

});