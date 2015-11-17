s.options.hardwareBufferSize = 1024;
(
//1: Record soundfile
fork {
    var inChannel = 1;
    var outChannel = 0;
    //PREP

    b= Buffer.alloc(s, 65536, 2);

    1.wait;
    b.write("/tmp/latency.wav", "wav", "int16", 0, 0, true);

    x = {
        var in = SoundIn.ar(inChannel);
        var sine = SinOsc.ar(65, 0.5 * pi) * Decay.ar(Impulse.ar(0.5));
        Out.ar(outChannel, sine * 1);
        DiskOut.ar(b, [DelayC.ar(sine, 0.2, 0.0), in]);
        DC.ar
    }.play;
    1.wait;
    x.free;
    b.close;
    b.free;
    "DONE".postln;
}
)
(
//2: Inspect soundfile
var hwSize = (s.options.hardwareBufferSize ? 512) * 2;
var assumedExtraLatency = 139;
w = Window.new("soundfile test", Rect(200, 300, 740, 100));
a = SoundFileView.new(w, Rect(20,20, 700, 60));

f = SoundFile.new;
f.openRead("/tmp/latency.wav");

a.soundfile = f;
a.read(0, f.numFrames);
a.elasticMode = true;

a.timeCursorOn = true;
a.timeCursorColor = Color.red;
a.timeCursorPosition = hwSize + assumedExtraLatency;
a.drawsWaveForm = true;
a.gridOn = true;
a.gridResolution = 0.2;
a.zoom((a.timeCursorPosition * 2) / f.sampleRate );

w.front;
a.mouseUpAction = {
    var latency = (s.options.hardwareBufferSize ? 512) * 2;
    "Time cursor position: %".format(a.timeCursorPosition).postln;
    "Buffer latency: %".format(latency).postln;
    "Remaining hardware latency: %".format(a.timeCursorPosition - latency).postln;
}
)


