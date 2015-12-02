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
~sndbuf = Buffer.read(s, "/Users/johannes/projects/timmer/_v1/render/testsound-mono.wav");
~sndbuf.normalize
b.fill(0,511,-1);
(
{ arg scrambleAmount=10, repeats=1, minLength=0.01;
	var snd = PlayBuf.ar(1, ~sndbuf);
	//var snd = SinOsc.ar(LFNoise2.ar(1).exprange(100, 400)) * 0.1;
	var maxXings=512;
	//var buf = LocalBuf(512);
    var buf = b;
	var durations = LocalBuf(maxXings);
    var buflength = 2.5;
    //reset every buflength
    var reset = Impulse.ar(buflength.reciprocal);
    //Trig on positive zero-crossings
	var trig = (Delay1.ar(snd) < 0) * (snd >= 0);
    //Measure time from last reset
    var time = Sweep.ar(reset);
	//Number of zero-crossings since last reset
	var writepos = Stepper.ar(trig, 0, 0, maxXings - 1, 1, 0);
    //Max position in buffer
    var max = RunningMax.ar(Delay1.ar(writepos));

	var readtrig, readpos, readtime, repeater, repeathold, delay, dur;

	//Write zero-crossing times into a buffer
    Demand.ar(trig, 0, Dbufwr(time, b, writepos));
	Demand.ar(trig, 0, Dbufwr(Timer.ar(trig), durations, (writepos - 1).wrap(0, maxXings - 1)));

	Demand.ar(trig, 0, Dbufrd(b, writepos)).poll;

    //Write previous duration in another buffer?

	//Get the delayed trigger from below
	readtrig = LocalIn.ar(1);
	repeater = Stepper.ar(readtrig, 0, 0, repeats - 1);
	//if we have repeats
	repeathold = Select.ar(repeats > 1, [repeater, readtrig]);
	//Get a random read position.
	readpos = Latch.ar(writepos - TIRand.ar(1, scrambleAmount+1, readtrig) - repeater, readtrig).wrap(0, max);
	//Get time for that position
	readtime = Demand.ar(readtrig, 0, Dbufrd(buf, readpos));
	//Subtract readtime from current time, wrapped to length of buffer
	//If scramble == 0, no delay (will cause clicks)
	delay = (scrambleAmount > 0) * Latch.ar((time - readtime), readtrig).wrap(0, buflength);
	//Latch.ar(time, readtrig).poll;
	dur = (Demand.ar(readtrig, 0, Dbufrd(durations, readpos)));

	//Feedback loop, initial impulse delayed so buffer is filled
	LocalOut.ar(TDelay.ar(readtrig, dur - ControlDur.ir) + TDelay.ar(Impulse.ar(0), (scrambleAmount*2)*minLength));

	snd = snd * 0.1;
	//SendReply.ar(readtrig);
	snd = DelayN.ar(snd, buflength, delay);

	snd
}.play
)

(
~delayBuf = Buffer.alloc(s, s.sampleRate * 2.5);
{ arg scrambleAmount=1, repeats=1, minLength=0.0;
	var snd = PlayBuf.ar(1, ~sndbuf);
	//var snd = SinOsc.ar(LFNoise2.ar(1).exprange(100, 400)) * 0.1;
	var maxXings=512;
	var buf = LocalBuf(maxXings);
    var durations = LocalBuf(maxXings);
    var buflength = 2.5;
    //reset every buflength
    var reset = Impulse.ar(buflength.reciprocal);
    //Trig on positive zero-crossings
	var trig = (Delay1.ar(snd) < 0) * (snd >= 0);
    //Measure time from last reset
    var time = Sweep.ar(reset);
	//Number of zero-crossings since last reset
	var writepos = Stepper.ar(trig, 0, 0, maxXings - 1, 1, 0);
    //Max position in buffer
    var max = RunningMax.ar(Delay1.ar(writepos));

	var readtrig, readpos, readtime, repeater, repeathold, delay, dur;

	RecordBuf.ar(snd, ~delayBuf, trigger: reset);

	//Write zero-crossing times into a buffer
    Demand.ar(trig, 0, Dbufwr(time, buf, writepos));
	//Write durations in another
	Demand.ar(trig, 0, Dbufwr(Timer.ar(trig), durations, (writepos - 1).wrap(0, maxXings - 1)));

	//Write previous duration in another buffer?

	//Get the delayed trigger from below
	readtrig = LocalIn.ar(1);
	repeater = Stepper.ar(readtrig, 0, 0, repeats - 1);
	//if we have repeats
	repeathold = Select.ar(repeats > 1, [repeater, readtrig]);
	//Get a random read position.
	readpos = Latch.ar(writepos - 10, readtrig).wrap(0, max);
	//Get time for that position
	readtime = (Demand.ar(readtrig, 0, Dbufrd(buf, readpos)) + Sweep.ar(readtrig)) * SampleRate.ir;

	(writepos - readpos).poll;

	//Latch.ar(time, readtrig).poll;
	dur = (Demand.ar(readtrig, 0, Dbufrd(durations, readpos)));

	//Feedback loop, initial impulse delayed so buffer is filled
	LocalOut.ar(TDelay.ar(readtrig, dur - ControlDur.ir) + TDelay.ar(Impulse.ar(0), (scrambleAmount*2)*minLength));

	//SendReply.ar(readtrig);
	snd = BufRd.ar(1, ~delayBuf, readtime);
	snd = BufRd.ar(1, ~delayBuf, Phasor.ar(readtrig, 1, 0, 2.5 * SampleRate.ir, readtime));
	snd = snd * 0.1;


	snd
}.play
)

