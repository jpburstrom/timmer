~buf4 = Buffer.read(s, "/Volumes/HD2/projects/timmer-2015/render/04-Qin 2 __-44100.wav");

(
Ndef(\fqShiftTest, {
    //Frequencies as multiples of EADG
    var freqs = ["E0", "A0", "D1", "G1"].namecps *.x [-5, -7, -11];
    var fadetime = 0.002;
    var sustain = 3.3;
    var snd = PlayBuf.ar(2, ~buf4, BufRateScale.kr(~buf4), startPos:44100*11.56);
    var chain = FFT(LocalBuf(512), snd[0]);
    var trig = Onsets.kr(chain, 0.2);
    //every onset has a probability of 0.1 to trigger a new chosen frequency
    var randFreq = Demand.kr(Impulse.kr(0) + CoinGate.kr(0.1, trig), 0, Dxrand(freqs, inf));

    //Delay to compensate for FFT latency
    snd = DelayN.ar(snd, 0.1, 512 / SampleRate.ir);

    //Random freq shift per onset
    // snd = LinXFade2.ar(snd, -1 * FreqShiftAA.ar(snd, randFreq), EnvGen.ar(Env([-1, -1, 1], [0.02, 0.05]), trig).lag(0.02));

}).play
)

x.free
x = { Impulse.ar(0.55) }.play