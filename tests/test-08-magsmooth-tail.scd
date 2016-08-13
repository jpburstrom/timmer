(
Ndef(\test, {
    var fx, in = In.ar(0, 2);
    var winsize = 16384;
    var delay = winsize / SampleRate.ir;
    var chain = FFT({LocalBuf(winsize)}.dup, in);
    chain = PV_MagSmooth(chain, TRand.kr(0, 0.5, Dust.kr(1)));
    chain = PV_MagSmear(chain, \smear.kr(10));
    fx = IFFT(chain) * Line.ar(dur:0.1);
    // fx = RLPFD.ar(fx, 391.9954 , 0.666, 0.666) * 3;
    fx = BHiShelf.ar(fx, 1200, 1, -9);
    fx = HPF.ar(fx, 200);

    in = DelayC.ar(in, delay, delay);
    in = XFade2.ar(in, fx, \pan.kr(0));
    ReplaceOut.ar(0, in)
})
.addSpec(\smear, [0, 512])
.addSpec(\smooth, \unipolar)
)
Ndef(\test).gui

