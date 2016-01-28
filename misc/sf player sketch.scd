b = Buffer.alloc(s, 262144, 2);
p = "Volumes/HD2/projects/timmer-2015/render/01-Preparerad flageolett 2 ___-44100.wav"

(
~player.free;
~player = Proto({
    ~buf = nil;
    ~path = nil;
    ~synthdef = \sfpx_2;
    ~synth = nil;
    ~soundFile = nil;

    (1..2).do { |i|

        SynthDef("sfpx_%".format(i).asSymbol, {
            Out.ar(\out.kr(0), DiskIn.ar(i, \buf.kr));
        }).add;
    };

    ~load = { |path, time(0)|
        ~path = path;
        path.postln;
        SoundFile.use(path, e { |f|
            ~soundFile = f;
            ~buf.free;
            ~buf = Buffer.alloc(s, 262144, f.numChannels);
        });
        ~buf.cueSoundFile(~path, time);
    };

    ~prPlay = {
        ~synth = Synth(~synthdef, [\out, 0, \buf, ~buf]);
        ~synth.register(true);
    };

    ~play = { |time|
        ~seek.value(time, true);
    };

    ~stop = {
        if (~synth.isPlaying) {
            ~synth.free;
            true
        } {
            false
        }
    };

    ~seek = { |time(0), play|
        var resume = ~stop.value;
        play = play || resume;
        s.makeBundle(nil, {
            ~buf.cueSoundFile(~path, time * ~soundFile.sampleRate);
            if (play) {
                ~prPlay.value;
            }
        })
    };

    ~free = {
        ~stop.value;
        ~buf.free;
    }


});
)

~player.load("/Volumes/HD2/projects/timmer-2015/render/01-Preparerad flageolett 2 ___-44100.wav");
~player.play
~player.play(10)
~player.stop
~player.free
