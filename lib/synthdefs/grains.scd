q.makeDefs (\synth,
    [
        \bufGrain,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum));
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)
        },
        nil,
        (channels:1)
    ],[
        \bufGrain2,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum));
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)

        }
    ],
    //--------RLPF/RHPF---------------
    [
        \bufGrainRLPF,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, ffreq=2000, rq=1;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum));
            snd = RLPF.ar(snd, ffreq, rq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)
        },
        nil,
        (channels:1)
    ],[
        \bufGrainRLPF2,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, ffreq=2000, rq=1;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum));
            snd = RLPF.ar(snd, ffreq, rq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)

        }
    ],[
        \bufGrainRHPF,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, ffreq=2000, rq=1;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum));
            snd = RHPF.ar(snd, ffreq, rq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)
        },
        nil,
        (channels:1)
    ],[
        \bufGrainRHPF2,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, ffreq=2000, rq=1;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum));
            snd = RHPF.ar(snd, ffreq, rq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)

        }
    ],
    //--------LPF/HPF---------------
    [
        \bufGrainLPF,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, ffreq=2000;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum));
            snd = LPF.ar(snd, ffreq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)
        },
        nil,
        (channels:1)
    ],[
        \bufGrainLPF2,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, ffreq=2000;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum));
            snd = LPF.ar(snd, ffreq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)

        }
    ],[
        \bufGrainHPF,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, ffreq=2000;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum));
            snd = HPF.ar(snd, ffreq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)
        },
        nil,
        (channels:1)
    ],[
        \bufGrainHPF2,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, ffreq=2000;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum));
            snd = HPF.ar(snd, ffreq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)

        }
    ]
);




