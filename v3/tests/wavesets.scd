w = Wavesets.from("/Volumes/HD2/projects/timmer/render/testsound-mono.wav");
Wavesets.prepareSynthDefs
(
Tdef(\wtest, {
    w.xings.size.do { |i|

        var ev = w.eventFor(i, 1, 2, 2, false);
        ev.put(\amp, 1);
        ev.play;
        ev.sustain.wait;
    }
}).play
)

b = Buffer.alloc(s, 512);
b.fill(0,511,-1);
(
x.free;
x = {
    var snd = SinOsc.ar(1);
    //var buf = LocalBuf(512);
    var buf = b;
    var buflength = 2.5;
    //reset every buflength
    var reset = Impulse.ar(buflength.reciprocal);
    //Trig on positive zero-crossings
    var trig = (snd <= 0) * (Delay1.ar(snd) > 0);
    //Measure time from last reset
    var time = Sweep.ar(reset);
    //Number of zero-crossings since last reset
    var writepos = Stepper.ar(trig, reset, 0, 1024, 1, 0);
    //Max position in buffer
    var max = RunningMax.ar(Delay1.ar(writepos), reset);
    //Write the time into a buffer
    Demand.ar(trig, reset, Dbufwr(time, b, writepos));
    //Write previous duration in another buffer?

    //Get a random read position

    //Get the duration of that xing

    //Put a delayed trigger on duration to read another

    //Non-working code starts here. We should:
    var trigfreq=1, readtrig = Impulse.ar(trigfreq);
    var readpos = (writepos - TRand.ar(1, 6, readtrig)).wrap(0, max);
    var delay = BufRd.ar(1, buf, readpos, 0, 1);
    trigfreq = (delay - BufRd.ar(1, buf, readpos + 1, 0, 1)).wrap(0, buflength).poll;
    SendReply.ar(readtrig);
    DelayC.ar(snd, buflength);
    DC.ar;
}.play
)

o = OSCFunc({ |msg| msg.postln }, '/reply');

{ Stepper.ar(Impulse.ar(Line.ar(0, 4))) }.plot(1)