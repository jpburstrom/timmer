(
SynthDef(\sampleTest, {
    Out.ar(0, PlayBuf.ar(1, \bufnum.kr, BufRateScale.kr(\bufnum.kr), loop:1).dup
        * EnvGen.kr(Env.linen(0.01, \sustain.kr, 0.01), \gate.kr(1), doneAction:2))
}).add;

)
Event
(
PR(\abstractProcess).clone {
    ~getFile = {
        "samples/Brygga-Loop*".resolveRelative.pathMatch.last;
    };
    ~preparePlay = {
        var file, server = ~server ? Server.default;
        (file = ~getFile.value) !? {
            ~buffer = Buffer.read(~server, file);
        };
        currentEnvironment;
    };
    ~asPattern = {
        Pbind(
            \dur, Pn(10,1),
            \instrument, \sampleTest,
            \bufnum, BPStream(\buffer)
        );
    };
    ~stopCleanup = {
        ~buffer.free;
    }

} => PR(\bryggaLoop);

PR(\bryggaLoop) =>.overwrite BP(\test);


BP(\test).play(1)

)
