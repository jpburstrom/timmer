q.makeDefs(\fx,
    [
        \bitCrushDelay,
        {
            arg snd, time=0.2, timelag = 0.1, feedback=0.36, lfreq=816, hfreq=100, mix=1, resolution=6;
            var local;
            feedback = feedback.min(0.9999999);
            local = HPF.ar(LPF.ar((LocalIn.ar(2) + snd).round(2.pow(resolution).reciprocal)
                , lfreq), hfreq);
            local = DelayC.ar(local, 2, Lag.kr(time, timelag));
            LocalOut.ar(local * feedback);
            local;
        }
    ]
);