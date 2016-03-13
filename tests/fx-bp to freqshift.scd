~buf = Buffer.read(s, "/Volumes/HD2/projects/timmer-2015/render/01-Preparerad flageolett 2 ___-44100.wav")

(
//STK
var wood1 = [[1.0, 2.777, 7.378, 15.377],		// Wood1
    [0.04, 0.01, 0.01, 0.008],
    [0.2, 0.15, 0.15, 0.06]];
var wood2 = [[1.0, 1.777, 2.378, 3.377],		// Wood2
    [0.04, 0.01, 0.01, 0.008],
    [0.2, 0.15, 0.15, 0.3]];


Ndef(\bpFreqShift, {
    arg freq = 1040, shift=0.2;

    var kfreq;
    var env;
    var snd = PlayBuf.ar(2, ~buf);
    // in = HPF.ar(in, 100);
    var bp;

    bp = BPF.ar(snd, freq, \rq.kr(0.02)).sum;



    // bp = snd.sum;

    bp = FreqShiftAA.ar(bp, (freq * shift.min(1)) - freq);
    // bp = bp * \ampx4.kr(1);

    bp = HPF.ar(bp, \hpf.kr(1000));
    bp = LPF.ar(bp, \lpf.kr(2000));

    bp = DynKlank.ar(`wood2, bp, 80, decayscale:\decayscale.kr(1)) * 10;

    //Filter freq shifted signal with formlet.
    //Make sure that freq shifted signal doesn't have too much of
    // bp = bp + ([120, 240].collect(Formlet.ar(bp, _, 0.005.rrand(0.05), LFNoise1.ar(2).range(0.1, 0.3))).sum);
    // bp = Ringz.ar(bp, 80, 1);
    // bp = BHiShelf.ar(bp, 800, 1, -32);


    // bp = bp.softclip; //safety measure

    bp = DelayC.ar(bp, 0.2, LFNoise2.kr(0.1).range(0.005, 0.01));

    // bp = Pan2.ar(bp, 0.6);

    // bp = [bp, DelayN.ar(bp, 0.2, 0.00001.rrand(0.0009))];


    // bp = bp + (x.ar(bp, 0.9) * 0.7);

    // bp = Balance.ar(bp, snd);

    SelectX.ar(\unipolar.kr, [bp, snd]).postln;



}).addSpec(\shift, [0.25, 1], \rq, \rq.asSpec.copy.maxval_(10)).mold.play
)


ControlSpec
Ndef(\bpFreqShift).gui

r = Ndef(\bpFreqShift).record("/tmp/test.wav")

r.resume
r.close

x = Synth(\plate_reverb_2x2, addAction:\addToTail);
x.set(\predelay, 80);
x.set(\decay, 0.8)
x.set(\amp, 0.05)