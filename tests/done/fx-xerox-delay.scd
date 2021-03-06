//Track & jump on zero crossings
//Could be adjusted to work with onsets or other triggers
//is a bit clicky, works best with noisier input

//Test sound
~bass = Buffer.read(s, "../player/songs/11-Bivax stråk ___-44100.wav".resolveRelative);
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
x = SynthDef(\zerox_delay, { arg sndbuf, timebuf, minDelay=0, maxDelay=0.1, density=10;
	//Sound source
	// var src = PlayBuf.ar(2, ~bass, startPos:110*44100);
	var src = SinOsc.ar(SinOsc.ar(1).exprange(80, 200), mul:0.1).dup;
	// var src = SinOsc.ar(100, mul:0.1).dup;
	//Make it mono for trigger
    var monosrc = src.sum;
    //Trig on zero crossing
    var trig = (monosrc > 0) * (Delay1.ar(monosrc) <=  0);
    var bufsize = BufFrames.ir(timebuf);
    //A phasor keeping track of time
    var rectime, playtime, time = Phasor.ar(0, 1, end:bufsize);
    //Sample and hold time on every trig
    var x = Latch.ar(time, trig);
    //We need to feed back time buffer output, so we use LocalIn
    var local = LocalIn.ar(1);
    //How much of the total buffer size is used to step back into
	var randWindow = LFNoise0.kr.range(minDelay, maxDelay.max(minDelay)) * bufsize;
    // var randWindow = Line.ar(0, bufsize, 120);

	randWindow.poll;
	//TODO: maybe BufWr/BufRd driven with `time` would be more accurate?
	BufWr.ar(x, timebuf, time);
	BufWr.ar(src, sndbuf, time);

	rectime = time;

    //### Playback ###
    //Get a random index into the buffer
    //Dust frequency can be adjusted to control how often a new index is generated
	//TODO: set lower bound for LFNoise range, to adjust delay min length
	x = Index.kr(timebuf, Latch.kr(time - randWindow, Trig.kr(Dust.kr(density), 0.01)).wrap(0, bufsize) );

    //trig on change from time buffer, if x has changed
    //This trigger should be aligned with playback
    local = Changed.ar(Latch.ar(x, local));

    //Play the time buffer, to get the time
    //Subtracted with blocksize to be one block ahead of time
	playtime = (time - Latch.ar(time - x, local));

	time = BufRd.ar(1, timebuf, (playtime + BlockSize.ir).wrap(0, bufsize), interpolation:0);

    //When time changes we send a trigger back to the playbuf above
    LocalOut.ar(Changed.ar(time));

    //And the `local` trigger is also used to trigger main playback
    //TODO: try with crossfades
	playtime = playtime.wrap(0, bufsize);

	//Bypass if randWindow == 0
	src = LinSelectX.ar(K2A.ar((randWindow > 0).lag(0.002)).poll, [src, BufRd.ar(2, sndbuf, playtime, interpolation:0)]);


    //Random pan is fun
	Out.ar(0, Balance2.ar(src[0], src[1], 0, \amp.kr(1)));

}).add
)
s.options.sampleRate = 44100
s.scope
x.set(\minDelay, 0)
x.set(\maxDelay, 0)
x = Synth(\zerox_delay, [\amp, 1, \sndbuf, ~sndbuf, \timebuf, ~timebuf])
x.free
x = 3.collect{ |i| var amp = i % 2 * 2 - 1; Synth(\zerox_delay, [\amp, amp, \sndbuf, ~sndbuf, \timebuf, ~timebuf]) }
x.do(_.set(\randWindow, 0.01))
x.do(_.free)
