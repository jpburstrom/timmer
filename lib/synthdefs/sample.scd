//A number of sample-based SynthDefs


//Simple PlayBuf and VDiskIn-based defs, just playing back files
q.makeDefs (\synth,
    [
        \playBuf,
        {
            arg bufnum=0, phase=0, rate=1, loop=0;
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum), loop:loop);
            FreeSelfWhenDone.kr(snd);
            snd
        },
        nil,
        (channels:1)
    ],[
        \playBuf2,
        {
            arg bufnum=0, phase=0, rate=1, loop=0;
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum), loop:loop);
            FreeSelfWhenDone.kr(snd);
            snd
        }
    ],[
        \playDisk,
        {
            arg bufnum=0, phase=0, rate=1, loop=0;
            var snd = VDiskIn.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, loop);
            FreeSelfWhenDone.kr(snd);
            snd
        },
        nil,
        (channels:1)
    ],[
        \playDisk2,
        {
            arg bufnum=0, phase=0, rate=1, loop=0;
            var snd = VDiskIn.ar(2, bufnum, BufRateScale.kr(bufnum) * rate, loop);
            FreeSelfWhenDone.kr(snd);
            snd
        }
    ]
)