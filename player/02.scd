(
var relPath = "".resolveRelative;
"lib/init".import;
q.player.actionLabels = #[phrase, beat];
q.player.tickLabel = \phrase;
q.player.loadData("02");
if (q.stereo.not) {
    q.player.channels = 9; //Bass, Freqshift, Resonator, Reverb, Piezo (1ch)
};
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
// q.playerui.connect(q.player);



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
    	count.yield;
     };

	(size - 1).yield
}));


q.player.setPtn(Pbind(
    \fadetime, 0.01,
    \instrument, \diskSegment,
    // \outbus, Pfunc {,
    //\outbus_mono, 8

));

q.player.parPtn = Ptpar([0.1, Pbind(
	\instrument, \resonate,
	\midinote, 28,
	\ctranspose, Prand([0,5,10,15], inf),
	\harmonic, Pwhite(3, 6),
	\group, Pfunc { ~t.postGroup },
	\dur, Pfunc { ~currentEvent.dur },
    \inbus, Pfunc { ~t.mainOut },
	\outbus, Pfunc { ~t.fxOut },
	\legato, 1,
	\release, 5,
	\db, (Pkey(\harmonic) - 2 ) * -2
)]);


q.player.onReady = {
    var compLookahead = 0.01;
    var revSize = 0.1;

    /*
	~t.irSpectrum = 2.collect {|i|
		Buffer.read(s, relPath +/+ "data/impulses/impulse-closed-ms-48_NRT_%.wav".format(i));
	};
	~t.convBus = Bus.audio(s, 2);
    s.sync;


    ~t.conv = Synth(\msConv, [\inbus, ~t.convBus, \outbus, stereo.if(2, 4), \irbufs, ~t.irSpectrum,
		\sideAmp, 1, \amp, 1
	], ~t.sendGroup);
    */

    ~t.freqshiftweird = Synth(\freqShiftWeird_02, [\inbus, ~t.mainOut, \outbus, ~t.fxOut], target:~t.postGroup);
  //POST FX
    ~t.softclip = Synth(\softclip,
        [\outbus, ~t.fxOut, \pregain, 4, \amp, 1],
        ~t.postGroup, \addToTail);
    ~t.compressor = Synth(\compressor,
        [\outbus, ~t.fxOut, \thresh, 0.25, \ratio, 8, \attack, compLookahead, \release, 0.1, \amp, 0.15],
        ~t.postGroup, \addToTail);
    //zap bad values before sending to verb
    ~t.zapper = Synth(\zapper, nil, ~t.postGroup, \addToTail);

    //SEND FX
    ~t.verb = Synth(\jpverb,
        [\inbus, ~t.fxOut, \outbus, ~t.fxOut, \amp, 0.2, \damp, 0.9, \size, revSize],
        ~t.sendGroup, \addToTail);

    //FIX FX LATENCY
    ~t.latencyFix = Synth(\fixedDelay,
        [\outbus, ~t.mainOut, \maxDelay, compLookahead, \delay, compLookahead],
        ~t.sendGroup, \addToTail);


};

)
/*EOF*/
q.player.play
q.player.bounce((sampleRate:96000))

q.player.t.conv.set(\amp, 0.25)
d = 100.collect {
q.player.generateScore.endTime
}

d.maxItem
d.minItem
d.sort.plot

