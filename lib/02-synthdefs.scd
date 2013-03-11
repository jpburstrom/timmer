
q.make({
    "Loading synthdefs".postln;

    q.makeSetup(\synthdefs, {
        (q.path.lib +/+ "synthdefs/*").loadPaths

    }, \boot);

});
