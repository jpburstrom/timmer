SynthDescLib(\timmer, { Server.default });

{ Toolbar.replace(\SynBrowse, { SynthDescLib.getLib(\timmer).browse }) }.defer;

q.make({
    "Loading synthdefs".postln;

    q.makeSetup(\synthdefs, {
        (q.path.lib +/+ "synthdefs/*").loadPaths

    }, \boot);

});
