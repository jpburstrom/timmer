
q.make({
    "Loading data".postln;

    ~data = ();


    //--------Song-specific data

    (
        snickargladje: {
            ~data.ampdur = Object.readArchive(~path.data +/+ "5.2-Snickarglädje.archive");
        }

    ).at(~song).value;

    ~envs = ().make {
        ~grain = ().make {
            //Envelopes, all scaled to 1 second
            ~rect = Env.linen(0.02, 0.96, 0.02); //almost, let's have some fade in and out
            ~tri = Env([0,1,0], [0.5,0.5]);
            ~hann = Env([0,1,0], [0.5,0.5], curve:\sin);
            ~tukey = Env.linen(0.25, 0.5, 0.25, curve: \sin);
            ~expodec = Env([0, 1, 0], [0.02, 0.98], curve: \cub);
            ~rexpodec = Env([0, 1, 0], [0.98, 0.02], curve: \cub);
            //approximate sinc
            ~sinc = Env([ 0, -0.0909, 0.1273, -0.2122, 1.0, -0.2122, 0.1273, -0.0909, 0 ],
                [ 0.0625, 0.125, 0.125, 0.1875, 0.1875, 0.125, 0.125, 0.0625 ],
                \sin);
        }
    };



})