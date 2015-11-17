b = Buffer.read(s, "/Volumes/HD2/projects/timmer/dokumentation/Inspelning 150222/150223_00.WAV")
ScoreClock.beginScore;
Task({
    b = Buffer.read(s, "/Volumes/HD2/projects/timmer/dokumentation/Inspelning 150222/150223_00.WAV");
    s.sync;
    x = {
        var snd = PlayBuf.ar(2, b, 0.5, startPos:10*44100);
        snd = FreqShift.ar(HPF.ar(snd, 98*11), -98*10);
        snd * 6;

    }.play;
    (12*60).wait;
    x.free;
    b.free;
}).play(ScoreClock)
~score = ScoreClock.makeScore

~score.recordNRT("/tmp/score.osc", "/tmp/fshift1.aiff")



b.free
b.close;
s.meter


ScoreClock