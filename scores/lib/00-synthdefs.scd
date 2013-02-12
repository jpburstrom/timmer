
q.make({
    "Loading synthdefs".postln;

    ~synthDefs = Setup({
        (q.path.lib +/+ "synthdefs/*").loadPaths

    }, \boot);

});

ServerTree.objects