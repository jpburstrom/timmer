SynthDef(\bufSegment, { |out(0), bufnum(0), startPos(0), sustain(1)|
    var fadetime = 0.02;
    var snd;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(out, snd);
}).add;
