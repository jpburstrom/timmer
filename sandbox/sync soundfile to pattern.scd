(

~test = Proto({

    ~soundFile = SoundFile("/Volumes/Mega/projects/timmer/samples/Gnid-20110825-002-nr.wav").info;
    ~view = nil;
    ~soundFileEvent = nil;


    ~pattern = Pbind(\dur, ~soundFile.duration / 8, \degree, Pseq((1..8)));

    ~makeGui = { |parent|
        ~view = SoundFileView();
        ~view.soundfile = ~soundFile;
        ~view.readWithTask(0, nil);
        ~view.timeCursorOn = true;

        ~view.keyDownAction = { |v, ch, mod, unicode, keycode|
            ~playFrom = v.timeCursorPosition;// * (~soundFile.sampleRate / 1000);
             ~player.isPlaying.postln;
            if (unicode == 32) { //Space
                if (~player.isPlaying) {
                    ~stop.()
                } {
                    ~play.()
                }
            }
        }.inEnvir;

        ~view.onClose = {
            ~stop.();
        }.inEnvir;
    };

    ~asPattern = {
        var from, dur;
        from = ~playFrom / ~soundFile.sampleRate;
        dur = ~soundFile.duration - from;
        dur.postln;
        Pspawner ( e { |sp|
            ~spawner = sp;
            ~cueSoundFile.();
            sp.wait(0.1);
            ~soundFileEvent.play;
            sp.par(~pattern.ff(from).finDur(dur))
        }).trace;
    };

    ~play = {
        "Play".postln;
        ~player = ~asPattern.().play;

    };
    ~stop = {
        "Stop".postln;
        ~player.stop;
        ~soundFileEvent.postln;
        ~soundFileEvent !? { ~soundFileEvent.stop; ~soundFileEvent.close;  };
        ~spawner !?  { ~spawner.suspendAll };

    };

    ~cueSoundFile = {
        var from = ~playFrom;
        var to = ~soundFile.numFrames;
        ~soundFileEvent = ~soundFile.cue((firstFrame: from, lastFrame:to))
    }

});

~test.makeGui.front


)
~test.copy("test")

Prout
(
Pspawner({ |sp|

    ~start = TempoClock.seconds.postln;
    sp.par(Pbind(\type, \soundFilePlayer, \ticks, Pseries(), \dur, 1/25));
    sp.par (Pbind(\degree, Pseq((0..7))));
    sp.wait(2);
    sp.par (Pbind(\degree, Pseq((0..7))))



}).ff(5).finDur(2).play

)


Event.addEventType(\soundFilePlayer, { |ev| currentEnvironment.postln } )

EventTypesWithCleanup

Event.default[\eventTypes][\off].postcs

Pbind().tempo

Pattern