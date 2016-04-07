(
"lib/init".import;
q.player.actionLabels = #[phrase, beat];
q.player.tickLabel = \phrase;
q.player.loadData("02");
// //FIXME: Player2 idea doesn't work
// q.player2 = q.player.clone;
// q.player2.tickLabel = \beat;
// q.player2.prepareScore;
// q.player2.setPtn(Pbind(
// 	\tempo, Pfunc { |ev| var t = ~data.beat[ev.beat][2]; t; },
// 	\dur, 1,
// 	\instrument, \plank
// ));
// q.player.parPtn = Pbind(\adjustDur, Pfunc { |ev| ev.dur = ev.dur * 0.5}) <> q.player2.asPattern
q.playerui.connect(q.player);


//Randomizing works a lot of the times, but not when
q.player.setIterator(Prout({
    var count = 0;
    var prob = 0.75; //Random jump probability
    var size = ~data.phrase.size;
	var nojump = [size-1, 25, 29, 30, 31]; //Indexes
	var score = Array.series(size - 1); //Save the last phrase for last
	while { score.size > 0 } {
	   if (prob.coin and: { nojump.includes(count).not } ) {
            count = score.choose;
        } {
			count = count + 1;
		};
		score.remove(count);
    	count.postln.yield;
     };

	(size - 1).yield
}));


q.player.setPtn(Pbind(\fadetime, 0.01));

q.player.parPtn = Ptpar([0.1, Pbind(
	\instrument, \resonate,
	\midinote, 28,
	\ctranspose, Prand([0,5,10,15], inf),
	\harmonic, Pwhite(3, 6),
	\group, Pfunc { ~t.postGroup },
	\dur, Pfunc { ~currentEvent.dur },
	\out, Pfunc { ~t.convBus },
	\legato, 1,
	\release, 5,
	\db, (Pkey(\harmonic) - 2 ) * -2
)]);


q.player.onReady = {
	~t.irSpectrum = 2.collect {|i|
		Buffer.read(s, "data/impulses/impulse-closed-ms-48_NRT_%.wav".format(i).resolveRelative);
	};
	~t.convBus = Bus.audio(s, 2);
	s.sync;
	~t.conv = Synth(\msConv, [\inbus, ~t.convBus, \outbus, 0, \irbufs, ~t.irSpectrum,
		\sideAmp, 1, \amp, 0.25
	], ~t.sendGroup);

	~t.freqshiftweird = Synth(\freqShiftWeird_02, target:~t.postGroup);



	~t.reverb = Synth(\plate_reverb_2x2, [\amp, -3.dbamp,
		\bandwidth, 5000, \decay, 0.1, \predelay, 10, \excursion, 0.9,
		\in_diff1, 0.36, \in_diff2, 0.40
	], ~t.sendGroup);

};

q.player.bounce
)


