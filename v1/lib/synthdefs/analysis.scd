// q.makeWindow

// Audio in  => Ctl out
// Could be several channels out:
// - Raw
// - Running average
// - RunningMax
// - RunningMin
// - ...
// in = bus, out = outbus


q.makeDefs(\ctla2k,
    [
        \anaOnsets,
        {
            arg snd, threshold=0.1, relaxtime=1, retrigTime=0.05, floor=0.5;
            var chain, onsets, buf = LocalBuf(512);
            // snd = Dust.ar(10); //testing
            chain = FFT(buf, snd);
            onsets = Onsets.kr(chain, threshold, relaxtime: relaxtime, floor:floor);
            onsets = Trig.kr(onsets, retrigTime);
            SendTrig.kr(onsets, 0, Timer.kr(onsets));
            onsets;
        },
        nil,
        (inChannels: 1, outChannels:1)
    ],
    [
        \anaPitch,
        {
            arg snd, freq, hasFreq;
            // snd.poll;
            freq = Tartini.kr(snd);
            //Trig from onsets, delayed so pitch can stabilize
            SendTrig.kr(DelayN.kr(\trig.kr), 0, freq[0]);
            freq
        },
        nil,
        (inChannels: 1, outChannels:2)
    ],
    [
        \anaSpectral,
        {
            arg snd;
            var buf, chain, centroid, flatness, onset;
            var delay, winSize = 2048;
            delay = (winSize * 2) / SampleRate.ir;
            buf = LocalBuf(2048);
            chain = FFT(buf, snd);
            centroid = SpecCentroid.kr(chain);
            flatness = SpecFlatness.kr(chain);
            centroid = MeanTriggered.kr(centroid, chain, 4);
            flatness = MeanTriggered.kr(flatness, chain, 4);

            //Send values back to lang
            onset = DelayN.kr(\trig.kr, delay, delay);
            SendTrig.kr(DelayN.kr(onset), 0, centroid);
            SendTrig.kr(DelayN.kr(onset), 1, flatness);

            [centroid, flatness];
        },
        nil,
        (inChannels: 1, outChannels:2)
    ],
    [
        \anaAmp,
        {
            arg snd, attack=0.1, release=0.1;
            Amplitude.kr(snd, attack, release);

        },
        nil,
        (inChannels: 1, outChannels:1)
    ]
);
