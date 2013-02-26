/**
How to work with this setup
*/

//Start with loading the init file, which returns a function.
//Call that function, giving it an Event as argument.
//The functions tied to the keywords synthdefs, bus, ctl, syn, ins and fx will be
//run in their respective Setup environment.
(
"lib/init.scd".loadRelative[0].(
    (
        song: \snickargladje,
        synthdefs: {
            "Making defs".postln;
            SynthDef(\fxTest, { arg bus, outbus=0; Out.ar(outbus, In.ar(bus) * SinOsc.ar(5, mul:0.1)) }).add;
            SynthDef(\lfoTest, { arg bus, freq=1; Out.kr(bus, SinOsc.kr(freq)) } ).add
        },
        bus: {
            "More busses".postln;
        },
        fx: {
            "More fx".postln;
            q.makeFx(\test, \fxTest)
        },
        ctl: {
            "More controls".postln;
            q.makeCtl(\test, \lfoTest, [\freq, 0.5])
        }
    )
);





)

//The main buses and order of execution is defined in the file "lib/01-nodes-buffers.scd".
//Also see Setup help file.
//
//There are a few predefined groups: in, ctl, syn, ins and fx.
//in  -- SoundIn wrappers.
//ctl -- LFO's and analysis, sending on a dedicated bus, by default control rate.
//syn -- Synths with or without input from in and ctl
//ins -- Insert effects, replacing the inputs with XOut or similar
//fx  -- Send effects, receiving from a dedicated bus.

//Any time you may add more nodes or buses:
q.bus.makeAdd { ~anotherBus = Bus.audio() };
q.grp.makeAdd { ~anotherGroup = Group() };

//The synths created like this will be respawned on ServerTree:
q.ctl.makeAdd { "Dummy function".postln };

//Synths created like this will not:
q.ctl.make { "Dummy function 2".postln };

//Accessing synths:
q.ctl.test

//Accessing buses:
q.bus.out1

//We also have some convenience functions, creating patterns:
q.pCtl(\test).asStream.nextN(2)
q.pCtlBus(\test).asStream.next
q.pFx(\test).asStream.next
q.pFxBus(\test).asStream.next
q.pBus(\out1).asStream.nextN(2)

//--------------Boilerplate-------------------

(
var ev = (
    song: \NEWSONG,

    synthdefs: {
    },
    bus: {
    },
    in: {
    },
    ctl: {
    },
    syn: {
    },
    ins: {
    },
    fx: {
    }
);
"lib/init.scd".loadRelative[0].(ev)

)

