SoundFile("/Volumes/Mega/projects/timmer/samples/greppbrada-1.wav").openInFinder


w = Wavesets.from("/Volumes/Mega/projects/timmer/samples/greppbrada-test-mono.wav")

Wavesets.prepareSynthDefs;

(
Task({
		// segments of 10 wavesets, step by 1 => 10x longer
	(0 .. 150).do { arg start;
		var ev = w.eventFor(0, numWs: 20, repeats: 2);

		ev.putPairs([\amp, 0.5, \playRate, 2]);
        ev.postln;
		ev.play;
		(ev.sustain).wait;
	};
	1.wait;

		// 1 waveset at a time, loop 10 times - much more 'pitch beads'-like
	(0 .. 150).do { arg start;
		var ev = w.eventFor(start, numWs: 1, repeats: 10);

		ev.putPairs([\amp, 0.5]);
		ev.play;
		(ev.sustain).wait;
	};

}).play;
)
(
s.latency = 0.2;
Pbind(
    \instrument, \wvst0,
    \buf, w.buffer,
    \playRate, 1,
    \frames, 1,
    \repeats, 1,
    \amp, 1,
    \counter, Pseries(),
    \index, Pfuncn( { |ev| var x = w.lengths.drop(ev.frames * -1).order.reverse; x[ev.counter % x.size] }, 100),
    //\index, 110,
    \start, Pfuncn({ |ev| w.xings[ev.index] }, inf),
    \length, Pfuncn({ |ev|
        w.xings[ev.index + ev.frames] - ev.start
    }, inf),
    \wsAmp, Pfuncn({ |ev| w.ampFor(ev.index, ev.frames) }, inf).trace,
    \amp, (1 - Pkey(\wsAmp)),
    \sustain, Pfuncn({ |ev| ((ev.length / w.sampleRate) / ev.playRate) * ev.repeats}, inf),
    \dur, Pkey(\sustain)
).play
)
Env([1, 1, 0], [2, 0]).plot