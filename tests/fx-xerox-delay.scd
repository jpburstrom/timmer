//Track & jump on zero crossings
//Could be adjusted to work with onsets or other triggers
//is a bit clicky, works best with noisier input

//Test sound
~bass = Buffer.read(s, "/Volumes/HD2/projects/timmer-2015/render/11-Bivax stråk ___-44100.wav");
~bass = Buffer.read(s, "/Volumes/HD2/projects/timmer-2015/render/08-Burk korta 2 ___-44100.wav");

//This might be a bit unnecessary -- triggers are logged in a buffer
//with the same size as `~sndbuf`. Because we need sample accurate triggers.
//If triggers were less frequent (eg onsets) it would be more wasteful
//An alternative then would be either to log both time and duration in two
//kr-buffers, or to send values to sclang
~timebuf = Buffer.alloc(s, s.sampleRate *10);
//
~sndbuf = Buffer.alloc(s, s.sampleRate * 10, 2);

(
x = SynthDef(\zerox_delay, { |bufnum|
    //Sound source
    var src = PlayBuf.ar(2, ~bass, startPos:110*44100);
    // var src = SinOsc.ar(mul:0.1).dup;
    //Make it mono for trigger
    var monosrc = src.sum;
    //Trig on zero crossing
    var trig = (monosrc > 0) * (Delay1.ar(monosrc) <=  0);
    var bufsize = BufFrames.ir(~timebuf);
    //A phasor keeping track of time
    var time = Phasor.ar(0, 1, end:bufsize);
    //Sample and hold time on every trig
    var x = Latch.ar(time, trig);
    //We need to feed back time buffer output, so we use LocalIn
    var local = LocalIn.ar(1);
    //How much of the total buffer size is used to step back into
    var randWindow = LFNoise0.ar.range(0, \randWindow.kr(0.01) * bufsize);
    // var randWindow = Line.ar(0, bufsize, 120);

    //TODO: maybe BufWr/BufRd driven with `time` would be more accurate?
    RecordBuf.ar(x, ~timebuf, loop: 1);
    RecordBuf.ar(src, ~sndbuf, loop:1);

    //### Playback ###
    //Get a random index into the buffer
    //Dust frequency can be adjusted to control how often a new index is generated
    //TODO: set lower bound for LFNoise range, to adjust delay min length
    x = Index.ar(~timebuf, Latch.ar(time - randWindow, Trig.ar(Dust.ar(10), 0.05)).wrap(0, bufsize) );

    //trig on change from time buffer, if x has changed
    //This trigger should be aligned with playback
    local = Changed.ar(Latch.ar(x, local));

    //Play the time buffer, to get the time
    //Adjusted (+64) to be one block ahead of time
    time = PlayBuf.ar(1, ~timebuf, 1, local, x+64, 1);

    //When time changes we send a trigger back to the playbuf above
    LocalOut.ar(Changed.ar(time));

    //And the `local` trigger is also used to trigger main playback
    //TODO: try with crossfades
    src = PlayBuf.ar(2, ~sndbuf, 1, local, x, 1);

    //Random pan is fun
    Out.ar(0, Balance2.ar(src[0], src[1], TRand.ar(-0.0, 0.0, local), 0.1));

}).play(s)
)
s.options.sampleRate = 44100
s.scope
x.set(\randWindow, 0.007)