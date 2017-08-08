(
//Static radio noise thing
SynthDef(\meckamack_07, { |bufnum|
    // PlayBufCF
    var fadetime = \fadetime.kr(0.02);
    var impchain, chain, noise, imp, amp, in, lop;
    var snd = VDiskIn.ar(2, bufnum, \rate.kr(1));
    // var snd = BufRd.ar(2, ~buf, LFNoise1.ar(LFNoise1.ar(0.1).range(0.001, 0.003)).range(300, 400).poll * BufSampleRate.kr(~buf));

    chain = FFT({LocalBuf(1024)}.dup, snd);
    noise = LFNoise1.ar(LFNoise0.kr(0.1).range(0.1,1)).range(0.02, 0.8);
    imp = BPF.ar(WhiteNoise.ar(1), \freq.kr(440), noise);

    lop = snd;
    1.do { lop = LPF.ar(snd, 8000) }; //Keep lows

    //Only freqshift highs
    //Less freqshift == less delay
    snd = FreqShiftAA.ar(DelayC.ar(snd - lop, 1, LFNoise1.kr(LFNoise0.kr(1).range(0.01,0.1)).range(0,01) * (\freqshift.kr(0) * -0.001)), \freqshift.kr);

    impchain = FFT({LocalBuf(1024)}.dup, imp);

    chain = PV_CopyPhase(impchain, chain);
    // chain = PV_MagSmooth(chain, 0.9);
    imp = IFFT(chain) * DelayC.ar(lop, 1, \noiseDelay.kr(0, \noiseDelayLag.kr(0)));


    // snd = XFade2.ar(snd, imp, \noiseMix.kr(0).linlin(0,1,-1,1));

    imp = imp * \noiseMix.kr(0);

    //snd = HPF.ar(snd, 60);

    snd = snd * EnvGen.ar(Env.asr(0.01, 1, 0.01), \gate.kr(1), doneAction:2);



    OffsetOut.ar(\outbus.kr, lop + snd + imp); //2 channels
    // snd.dup
}).add;
)

