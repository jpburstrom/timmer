b = Buffer.read(s, "/Volumes/Mega/projects/timmer/render/to SC/silent arco test.wav");

(
w = Window().front;
DragSink(w, Rect(0, 0, 300, 50)).receiveDragHandler_ {
    b.free;
    b = Buffer.read(s, View.currentDrag.value);
}
)


{ Splay.ar(PlayBuf.ar(1, b, (-12,-8..0).midiratio * BufRateScale.kr(b) , loop:1)) }.play
(-12,-10..0).midiratio


(
Tdef(\boreLauncher, {
    Ndef(\bore).play;
    10.do { |i|

        "hello".postln;
        10.wait;
    }

}).play;
)
(
Ndef(\bore, { arg shift = -10;
    var ishift = (shift * -1).max(5);
    var snd = Splay.ar(PlayBuf.ar(1, b, 1 * BufRateScale.kr(b), 1, 0.rrand(1.0) * BufFrames.kr(b), loop:1));
    //var snd = BufRd.ar(1, b, ({ LFTri.ar(LFNoise2.kr(0.03, 0.05)) } ! 2) * BufFrames.kr(b));

    4.do {    snd = HPF.ar(snd, ishift); };
    snd = FreqShift.ar(snd, shift);
    snd = Line.ar(dur:0.1) * snd;
})
)
Ndef(\bore).fadeTime_(0.2)
Ndef(\bore).lag(\shift, 0.06)
Ndef(\bore).set(\shift, -800)


