q.makeDefs (\synth,
    [
        \bufGrain,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, loop=0;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum), loop:loop);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)
        },
        nil,
        (channels:1)
    ],[
        \bufGrain2,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, loop=0;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum), loop:loop);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)

        }
    ],
    //--------RLPF/RHPF---------------
    [
        \bufGrainRLPF,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, loop=0, ffreq=2000, rq=1;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum), loop:loop);
            snd = RLPF.ar(snd, ffreq, rq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)
        },
        nil,
        (channels:1)
    ],[
        \bufGrainRLPF2,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, loop=0, ffreq=2000, rq=1;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum), loop:loop);
            snd = RLPF.ar(snd, ffreq, rq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)

        }
    ],[
        \bufGrainRHPF,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, loop=0, ffreq=2000, rq=1;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum), loop:loop);
            snd = RHPF.ar(snd, ffreq, rq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)
        },
        nil,
        (channels:1)
    ],[
        \bufGrainRHPF2,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, loop=0, ffreq=2000, rq=1;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum), loop:loop);
            snd = RHPF.ar(snd, ffreq, rq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)

        }
    ],
    //--------LPF/HPF---------------
    [
        \bufGrainLPF,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, loop=0, ffreq=2000;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum), loop:loop);
            snd = LPF.ar(snd, ffreq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)
        },
        nil,
        (channels:1)
    ],[
        \bufGrainLPF2,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, loop=0, ffreq=2000;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum), loop:loop);
            snd = LPF.ar(snd, ffreq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)

        }
    ],[
        \bufGrainHPF,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, loop=0, ffreq=2000;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum), loop:loop);
            snd = HPF.ar(snd, ffreq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)
        },
        nil,
        (channels:1)
    ],[
        \bufGrainHPF2,
        {
            arg bufnum=0, phase=0, rate=1, sustain=1, loop=0, ffreq=2000;
            var env = Env.newClear(8);
            var envctl = \env.kr(env.asArray);
            var snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate,
                startPos: phase*BufFrames.kr(bufnum), loop:loop);
            snd = HPF.ar(snd, ffreq);
            snd * EnvGen.ar(envctl, timeScale:sustain, doneAction:2)

        }
    ]
);

//----------SCANNER----------------
q.makeDefs(\synth,
    [
        \scanner,
        {
            arg bufnum, freq = 50, speed = 0.01, gate=1, phase = 0, envbuf = -1,
            phaseDev = 0,
            attack=0.01, decay = 0.3, sustainLevel = 1, release = 0.1;
            var trig, pos, len;
            freq = freq * (1 - speed); //Adjust freq to buffer reading speed
            trig = Impulse.ar(freq);
            len = BufFrames.kr(bufnum) / BufSampleRate.kr(bufnum);
            pos = (Line.ar(phase, dur: (len - phase) / speed)
                + (LFNoise1.ar(freq, freq.reciprocal * phaseDev))).wrap(0, 1);
            GrainBuf.ar(1, trig, freq.reciprocal, bufnum, 1, pos, envbufnum: envbuf)
            * EnvGen.ar(Env.adsr(attack, decay, sustainLevel, release), gate, doneAction:2)
        }, nil, (channels:1)
    ], [
        \scanner2,
        {
            arg bufnum, freq = 50, speed = 0.01, gate=1, phase = 0, envbuf = -1,
            phaseDev = 0,
            attack=0.01, decay = 0.3, sustainLevel = 1, release = 0.1;
            var trig, pos, len;
            freq = freq * (1 - speed); //Adjust freq to buffer reading speed
            trig = Impulse.ar(freq);
            len = BufFrames.kr(bufnum) / BufSampleRate.kr(bufnum);
            pos = (Line.ar(phase, dur: (len - phase) / speed)
                + (LFNoise1.ar(freq, freq.reciprocal * phaseDev))).wrap(0, 1);
            GrainBuf.ar(1, trig, freq.reciprocal, bufnum, 1, pos, envbufnum: envbuf)
            * EnvGen.ar(Env.adsr(attack, decay, sustainLevel, release), gate, doneAction:2)
        }
    ]
);

//----------SCANNER----------------
q.makeDefs(\synth,
    [
        \scannerDust,
        {
            arg bufnum, freq = 10, density=4, gate=1, phase = 0, envbuf = -1,
            phaseDev = 0, rate=1,
            attack=0.01, decay = 0.3, sustainLevel = 1, release = 0.1;
            var trig, pos, len;
            trig = Dust.ar(freq);
            pos = (phase + (LFNoise1.ar(freq, freq.reciprocal * phaseDev))).wrap(0, 1);
            GrainBuf.ar(1, trig, freq.reciprocal * density, bufnum, rate, pos, envbufnum: envbuf)
            * EnvGen.ar(Env.adsr(attack, decay, sustainLevel, release), gate, doneAction:2)
        }, nil, (channels:1)
    ], [
        \scannerDust2,
        {
            arg bufnum, freq = 10, density=4, gate=1, phase = 0, envbuf = -1,
            phaseDev = 0, rate=1,
            attack=0.01, decay = 0.3, sustainLevel = 1, release = 0.1;
            var trig, pos, len;
            trig = Dust.ar(freq);
            pos = (phase + (LFNoise1.ar(freq, freq.reciprocal * phaseDev))).wrap(0, 1);
            GrainBuf.ar(1, trig, freq.reciprocal * density, bufnum, rate, pos, envbufnum: envbuf)
            * EnvGen.ar(Env.adsr(attack, decay, sustainLevel, release), gate, doneAction:2)
        }
    ]
);


