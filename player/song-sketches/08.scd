~buf8 = Buffer.read(s, "/Volumes/HD2/projects/timmer-2015/render/08-Burk korta 2 ___-44100.wav");
~grainBuf = Buffer.alloc(s, 44100, 1);

(
Ndef(\fqShiftTest8, {
    //Frequencies as multiples of EADG
    var freqs = ["E0", "A0", "D1", "G1"].namecps *.x [-5, -7, -11];
    var fadetime = 0.002;
    var sustain = 3.3;
    var snd2, snd = PlayBuf.ar(2, ~buf8, BufRateScale.kr(~buf8), startPos:0 * 44100);
    var chain = FFT(LocalBuf(512), snd[0]);
    //every onset has a probability of 0.1 to trigger a new chosen frequency
    var singletrig = Onsets.kr(chain, 0.1);
    var trig = Impulse.kr(0) + CoinGate.kr(0.1, singletrig);
    var freq = Latch.kr(LFNoise2.kr(0.05).exprange(-2000, -8000), trig);
    var lin = LocalIn.ar(2);

    var flag, flag2;

    var dronefreq, dronefreqs = ((0..11) + 36).midicps * 3;

    //Delay to compensate for late onset detection
    snd = DelayN.ar(snd, 0.1, 0.095);

    //Treat a single harmonic
    flag = BPF.ar(snd, 490, 0.01);
    flag = Mix.fill(3, { FreqShift.ar(flag, LFNoise2.ar(0.1).range(-10, 10), mul:1) });

    snd2 = FreqShiftAA.ar(snd, freq) * 24.dbamp;
    snd2 = Compander.ar(snd2, snd2, 0.01, 10, 0.1, 0.01, 0.5);

    snd2 = DelayC.ar(snd2, 0.1, LFNoise2.ar(0.1).range(0,0.05));


    lin = DelayC.ar(LPF.ar(snd2 + lin, 1000), 1, LFSaw.ar(0.33).exprange(1.5, 0.0001), 0.5);

    lin = Balance2.ar(lin[0], lin[1], -0.33);

    LocalOut.ar(LeakDC.ar((lin * 10).tanh * 0.1));

    // snd = LinSelectX.ar(K2A.ar(TIRand.kr(0, 12, singletrig) < 1).lagud(0.5, 0.05).poll, [snd, FreqShiftAA.ar(snd, MouseX.kr(0, -4000))]);

    dronefreq = \dronefreq.kr([100, 120], 0.1);
    // dronefreq = LFNoise2.ar(1).range(100, 200).lag(0.2);
    // dronefreq = 100;


    snd = snd + Mix(LPF.ar(CombC.ar(BBandStop.ar(snd, dronefreq), 0.2, dronefreq.reciprocal, LFNoise2.kr(0.3).range(-0.1, EnvGen.kr(Env([-20, -20, -0.2], [0, 10], \exp), \combTrig.kr(1)))), LFNoise2.kr(0.5).exprange(100, 200), 0.1)).dup;

    snd = snd + lin;

    flag + snd;

    // flag2

}).play
)

(0..11).choose !2

Ndef(\fqShiftTest8).set(\dronefreq, {((0..11) + 36).midicps.choose}.dup(2) * 3)

Ndef(\fqShiftTest8).set(\combTrig, 0);
Ndef(\fqShiftTest8).set(\combTrig, 1);