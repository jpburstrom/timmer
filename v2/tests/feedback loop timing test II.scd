Ndef(\test, { SinOsc.ar(45.midicps) * 0.1 }).play
Ndef(\test).stop

"B1".namemidi

{
    var plotter;
    q.launchPad.elementAt(\bt, 0).action = { |el |
        if (el.value == 1) {
            defer {
                plotter !? { plotter.parent.close };
                plotter = { InFeedback.ar(32, 2) }.plot

            }
        }
    }
}.value


//Den här verkar funkar ok som test
//706 samples = 0.014708333 @ 48000
(
Ndef(\test, {
    var freq = \freq.kr(60);
    var period = freq.reciprocal;
    var initialDelay = \delayInSamples.kr(256) / 48000;
    var in = DelayC.ar(SoundIn.ar(0), 0.2,
        (( period - initialDelay) % period))
    * 0.1;
    var out = SinOsc.ar(freq) * 0.01;
    Out.ar(4, out);
    Out.ar(32, [in*10, out*10*\amp.kr, (in-(out*\amp.kr * 2))*10]);

    DC.ar
}).gui
)
Ndef(\test).addSpec(\delayInSamples, [1, 1024, \lin, 1, 128]);

q.tree.synths[\60].set(\rq, 0.0189)
