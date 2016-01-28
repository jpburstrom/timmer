p = Proto({
    ~path = "/Volumes/HD2/projects/timmer-2015/render/01-Preparerad flageolett 2 ___-44100.wav";

    ~load = { |path|
        if (path.notNil) {
            ~path = path;
        };
        ~synthdef = SynthDef(\bufSegment, { |out(0), buf(0), startPos(0)|
            var fadetime = 0.02;
            var snd;
            startPos = ((startPos - fadetime) * BufSampleRate.kr(buf)).max(0);
            snd = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * \bufRate.kr(1), 1, startPos, doneAction:2);
            snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, 0, fadetime], releaseNode:2), \gate.kr(1), doneAction:2);
            OffsetOut.ar(out, snd);
        }).add.name;
        ~buf = Buffer.read(s, ~path);
    };

    ~prPlay = { |time|
        if (~synthdef.notNil) {
            ~synth = Synth(~synthdef, [\out, 0, \buf, ~buf, \startPos, time]);
            ~synth.register(true);
        } {
            "Not prepared for playing".warn;
        }
    };

    ~play = { |time|
        ~stop.value;
        ~prPlay.value(time);
    };

    ~stop = {
        if (~synth.isPlaying) {
            ~synth.release;
            true
        } {
            false
        }
    };

    ~cleanup = {
        ~stop.value;
        ~buf.free;
    }

});