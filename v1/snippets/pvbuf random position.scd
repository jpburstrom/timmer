/*
Köra runt i en PV_buf med random position.
För förinspelade ljud kan man skriva pv_buffers till disk
Det är riskabelt att spela in till samma pv_buffer som man läser ifrån
En variant vore att växla mellan två/tre pv_buffers och korsfejda mellan dem:
buf1.rec;
buf2.rec; buf1.play;
buf3.rec; buf1+2.play; (xfade)
buf1.rec; buf2+3.play;

*/

//FIRST
(
var path = "/Volumes/Mega/projects/timmer/kod/sc/samples/greppbrada-1.wav";
// var path = "/Volumes/Mega/projects/timmer/render/to SC/granul-samples/arcodrone.wav";
var windowSize = 4096;
var len = 3;

~soundbuf = Buffer.readChannel(s, path, channels:[0]);
~buf = Buffer.alloc(s, len.calcPVRecSize(windowSize, 0.25));
{
    var syn = {
        var snd, chain, buf = LocalBuf.new(windowSize);
        snd = PlayBuf.ar(1, ~soundbuf, 1.5);
        chain = FFT(buf, snd, 0.25, 1);
        chain = PV_RecordBuf(chain, ~buf, 0, 1, 1, 0.5)
        ;DC.ar(0);
    }.play;
    len.wait;
    syn.free;
    "Done".postln;
}.fork
)

//NEXT
(
var windowSize = 4096;
var len = 3;
var buffer = ~buf;

if (buffer.notNil) {
    z = {
        var chain, buf = LocalBuf.new(windowSize);
        var pos = LFNoise1.kr(len.reciprocal).range(0.1, 0.9);
        chain = PV_BufRd(buf, buffer, pos);
        Splay.ar(IFFT(chain) + Warp1.ar(1, ~soundbuf, pos, 1.5, windowSize: 0.5, mul:1));

    }.play;
} {
    "Buffer is nil".warn;
}

)
