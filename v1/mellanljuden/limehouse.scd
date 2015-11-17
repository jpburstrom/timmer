b = Buffer.read(s, "/Volumes/Mega/projects/timmer/render/to SC/gnek test nr.wav")
c = Buffer.read(s, "/Volumes/Mega/projects/timmer/samples/Brygga-Loop-20140102-1532-XF.wav")

(
Ndef(\limehouse, {
    var snd = 3.collect({ |i|
        PlayBuf.ar(2, b, BufRateScale.kr(b) * Rand(0.667,1), startPos: 0.rrand(BufFrames.kr(b)), loop:true) * XLine.ar(2, 1, i * 5);
    }).flop.flatten;

    var dur = 180;

    var f = Line.kr(8000, 400, dur).poll(1);
    //var f = XLine.kr(400, 16000, dur);

    snd = snd.collect { |ch, i|
        var shift = f + (i * 100);
        4.do { ch = HPF.ar(ch, shift) };
        FreqShift.ar(ch, shift * -1);
    };
    snd = Splay.ar(snd, Line.ar(0.5, 1, dur));
    snd = HPF.ar(snd, XLine.kr(50, 300, dur));
    snd = Pan2.ar(Formlet.ar(Mix(snd), LFNoise1.kr(0.1).range(28, 33).midicps, 0.01, 0.1), LFNoise1.ar(0.2, 0.5)) + snd;
    snd = Balance2.ar(snd[0], snd[1], Line.ar(0, Rand(-1, 1), dur));
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [0.05, dur + 10, 0.5], -4), doneAction:2);
    LeakDC.ar((snd * 64).tanh * 0.2);
}).play;
)

Ndef(\loopo, {
    2.collect { PlayBuf.ar(1, c, BufRateScale.kr(c), startPos: Rand(0, BufFrames.kr(c)), loop:1) }
}).play;

(
fork {
    Ndef(\test).play;
    189.5.wait;
    Ndef(\loopo).play;
}
)