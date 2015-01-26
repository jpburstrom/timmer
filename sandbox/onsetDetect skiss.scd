b = Bus.control(s)

(
SynthDef(\onsetDetect, {
    arg out=b, threshold=0.1, relaxtime=1, pingAmp=0.2;
    var chain, onsets, snd,
    buf = LocalBuf(512);
    snd = SoundIn.ar(0);
    chain = FFT(buf, snd);
    onsets = Onsets.kr(chain, threshold, relaxtime: relaxtime);
    SendTrig.kr(onsets);
    // snd
    Out.kr(out, onsets); //test
    Out.ar(0, WhiteNoise.ar(EnvGen.kr(Env.perc(0.001, 0.1, pingAmp), onsets)).dup);

}).add;

)
a = Synth(\onsetDetect)
a.set(\pingAmp, 0)
//For continous controllers, you could do this:
(
{

    loop {
        b.get { arg x; x.postln };
        0.1.wait;
    }
}.fork
)
