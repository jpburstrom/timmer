Tdef.defaultQuant = 0;
Pdef.defaultQuant = 0;


q.make({
    "Loading synthdefs".postln;

    q.makeSetup(\synthdefs, {
        (q.path.lib +/+ "patterns/*").loadPaths

    }, \boot);

});


