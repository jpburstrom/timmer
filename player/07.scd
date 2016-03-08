//# Song 07 ###

//## Form ###
//### A ###
//First minute: low bass, feedback loop. Dynamic duration. Possibly crossfade phrases,
//or put them on top of each other.

//### B ###
//1.00. Low bass continues, first pizz after roughly 10 seconds. Here feedback might be gone.

//### C ###
//2.45. Short bridge followed by long drone-noisy sausage. Here feedback is back.

//## Initialize ###
(
"lib/init".import;
q.player.actionLabels = #[phrase, part];
q.player.tickLabel = \phrase;
q.player.loadData("07");
//q.player.extractFeatures;
q.playerui.connect(q.player)
)
(

//## Patterns #######

//This sets a pattern used to modify the base player pattern.
q.player.setPtn(Pbind(
	\combSetFunc, p { |ev|
		var target = ~data.firstPartRepeat;
		// var targetVal = -0.
		var leakCurve = Pseg2([0,0.6], target+1, 4).asStream;
		var fbCurve = Pseg2([2.9, 9], target+1, 4).asStream;
		// var lfbCurve = Pseg2([0.59, -9], target+1, -4).asStream;
		var stretch = Pseries(1, 0.001).asStream;
		var freqs = #[81,102,242,404] *.x [1,2];


		loop {
			//Only set if not nil (assuming all streams have equal length)
			leakCurve.next !? { arg leak;
				s.bind {
					~t.comb.set(\partials, freqs * Array.geom(8, 1, stretch.next));
					~t.comb.set(\leak, leak);
					~t.comb.set(\maxFeedback, fbCurve.next);
					// ~t.comb.set(\minFeedback, lfbCurve.next);

				};
			};

			ev = 0.yield;
		};
	}

));

// q.player.setIterator(Pn(q.player.data.phrase.size - 1, 1))

//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(
    Plazy({
        var part = ~data.lookup.part;
        var repeatFirst = 1;//4.rrand(8);
		~data.firstPartRepeat = repeatFirst;
        Pseq([
			Pxrand(Array.series(part[1]-1, 0), repeatFirst),
			Pseries(part[1]),
        ])
    })
);
)
q.player.setIterator(Pseries())
//## Callbacks ####
(
//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar
q.player.onReady = {

	~t.comb = Synth(\feedback_07, [\amp, -40.dbamp], target: ~t.postGroup)

};

q.player.actions.part.onStart = { |ev, part|
	q.playerui.log(part, "Part");
	switch(part,
		1, {
			~t.rout = fork {
				11.5.wait; //Wait for first pizz
				s.bind {
					//Continue feedback loop without support from bass
					~t.comb.set(\inAmp, 0);
					~t.comb.set(\minFeedback, -5);
					~t.comb.set(\ampAutoscale, 0.9);

				}
			}
		},
		2, {
			~t.rout.stop; //Stop previous routine (if still active)
			s.bind {
				"hello part 3".postln;
				~t.envBus = Bus.control(s);
				~t.env = { Out.kr(~t.envBus, EnvGen.kr(Env([0.9, 0.1], [60]))); }.play(target:~t.preGroup);
				~t.comb.map(\ampAutoscale, ~t.envBus);
				~t.comb.set(\partials, 102 * (1..8));
			}
	});
}
)


q.player.trace = true
q.player.play
q.player.stop
q.player.readyForPlay

x = fork { 10.do { "hello".postln; 1.wait }}

x.stop