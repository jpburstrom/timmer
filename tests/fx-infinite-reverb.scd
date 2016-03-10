~buf = Buffer.read(s, "/Volumes/HD2/projects/timmer-2015/render/01-Preparerad flageolett 2 ___-44100.wav", 22000)


~buf


(


{ arg feedback = 0.9;
    var snd = PlayBuf.ar(2, ~buf);
    var input = snd;
    var local;

    // input = (snd * EnvGen.ar(Env([0, 0, 1, 0], [0.35, 0.2, 0.3])));


    //Possible autoscale
    var env = (1 - Fdef(\autoscale).value(Amplitude.kr(input.sum, 0.01, 15)));

    local = LocalIn.ar(2) + (DelayC.ar(input, 0.05, 0.05) * env.cubed);

    25.do { local = AllpassN.ar(local, 0.06, Rand(0.001, 0.016), 3) };

    LocalOut.ar(local * feedback);

    [snd, K2A.ar(env)];

    snd + local

}.play

)
s.scope
