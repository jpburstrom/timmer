
q.make({
    "Loading data".postln;

    ~data = ();


    //--------Song-specific data

    (
        snickargladje: {
            ~data.ampdur = Object.readArchive(~path.data +/+ "5.2-Snickarglädje.archive");
        }

    ).at(~song).value;


})










