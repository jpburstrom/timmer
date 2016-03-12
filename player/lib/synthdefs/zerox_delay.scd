//Zero-crossing-respecting scrambled delay
//Two parts:
//- \zerox_delay_rec_[1|2] is recording an input (1 or 2 channels) to a buffer, as well as zero crossings to another buffer
//- \zerox_delay_[1x2|2x2] is playing back the contents of the buffer, while randomly jumping to other zero crossings inside a set time window, with a variable frequency.

var zerox_play = { arg channels, inbus = 0, outbus=0, posbus=0, sndbuf, timebuf, minDelay=0, maxDelay=0.1, density=10, pan=0, amp=1;

	var src = In.ar(inbus, channels);
	var time = In.ar(posbus); //record location
	var bufsize = BufFrames.kr(timebuf);

	//How much of the total buffer size is used to step back into
	var randWindow = LFNoise0.kr.range(minDelay, maxDelay.max(minDelay)) * bufsize;
	//We need to feed back time buffer output, so we use LocalIn
    var local = LocalIn.ar(1);
	var playtime;

	var x = Index.ar(timebuf, Latch.ar(time - randWindow, Trig.ar(Dust.ar(density), 0.01)).wrap(0, bufsize) );

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
	src = LinSelectX.ar(K2A.ar((randWindow > 0)).lag(0.002), [src, BufRd.ar(channels, sndbuf, playtime, interpolation:0)]);

	//Assuming channels are 1 or 2
	//TODO: variable panning?
	if (channels == 1) {
		Out.ar(outbus, Pan2.ar(src, pan, amp));
	} {
		Out.ar(outbus, Balance2.ar(src[0], src[1], pan, amp));
	};
};

[1,2].do { |channels|
	SynthDef("zerox_delay_rec_%".format(channels), { arg inbus = 0, posbus = 0, sndbuf, timebuf;
		//Make it mono for trigger
		// var src = In.ar(inbus, channels);
		// var src = SinOsc.ar *0.1 ! channels;
		var src = In.ar(inbus, channels);
		var monosrc = src.asArray.sum;
		//Trig on zero crossing
		var trig = (monosrc > 0) * (Delay1.ar(monosrc) <=  0);
		var bufsize = BufFrames.kr(timebuf);

		//A phasor keeping track of time
		var time = Phasor.ar(0, 1, end:bufsize);
		//Sample and hold time on every trig
		var x = Latch.ar(time, trig);

		//TODO: maybe BufWr/BufRd driven with `time` would be more accurate?
		BufWr.ar(x, timebuf, time);
		BufWr.ar(src, sndbuf, time);

		//Output current record time
		Out.ar(posbus, time);

	}).add;
};

SynthDef(\zerox_delay_1x2, zerox_play, prependArgs:[1]).add;
SynthDef(\zerox_delay_2x2, zerox_play, prependArgs:[2]).add;


/*
g = 3.collect {Group() }; g.doAdjacentPairs { arg a, b; b.moveAfter(a) };
Synth(\zerox_delay_2x2, [\sndbuf, ~sndbuf, \timebuf, ~timebuf])

x = {SinOsc.ar(SinOsc.ar(1).exprange(80, 200)).dup * 0.1}.play(target:g[0])
y = Synth(\zerox_delay_rec_2, [\outbus, 32, \inbus, 0, \sndbuf, ~sndbuf, \timebuf, ~timebuf], g[1]);
z = Synth(\zerox_delay_2x2, [\outbus, 0, \inbus, 0, \timebus, 32, \sndbuf, ~sndbuf, \timebuf, ~timebuf], g[2]);

x.free; y.free; z.free

*/
