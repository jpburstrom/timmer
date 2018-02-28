//# Some tests ###

//```
//test.scd
//Part of Timmer
//Johannes Burström 2016
//```

//## Initialize ###
(
//Init, creates q.player and q.playerui
"lib/init".import;

//ActionLabels are marker lists from Sonic Visualiser
q.player.actionLabels = #[onset, region];

//The tick label is the main marker list, used by the player iterator
q.player.tickLabel.debug("Tick label");

//Load data from data/01/*
q.player.loadData("01");

//Extract features
//Make segments with 5 frames from every onset
//and create a KDTree at q.player.kdTree
q.player.extractFeatures;


//Open and connect a UI to our player
q.playerui.connect(q.player)
)
(

//## Patterns #######

//This sets a pattern used to modify the base player pattern.
q.player.setPtn(Pbind(
	\amt, Pseg([0.5, 0], 25, \sin), //Pif(Pwhite(hi:0.6).coin, Pwhite(0, 0.35), Pseg([0,0.4,0], 20, \sin, inf)),
	\dur, Fdef(\changePatternEndTime).(\amt),
    \outbus, Pif(Pkey(\dur) < 0.35, Pfunc { ~t.fxbus } , 0)
));
//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(p { |ev|
	var i = 0;
	var radius = 0.1;
	loop {
		i = i + 1;
		ev = ~data.kdTree.radiusSearch(~data.featureClump[i], radius).choose.label.yield
	}
});
)

//## Callbacks ####
(
//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar
q.player.onReady = {
    //Create a bus to use for post fx
    //use ~t to make it available to patterns
    //and to automatically free it after pattern is done playing
    ~t.fxbus = Bus.audio(s, 2);

    { var snd = In.ar(~t.fxbus, 2); FreqShift.ar(snd, -100) }.play(target: ~t.postGroup);

};
)
//All labels have actions onStart and onStop, with index as args
q.player.actions.region.onStart = { |...args| args.postln };
q.player.actions.region.onStop = { |...args| ("stop" ++ args).postln };

//If a region is changing (directly from one to another),
//we call onChange.value(prevIndex, nextIndex).
//If a region change is not linear, we call onJump.value(prevIndex, nextIndex)

//Like this:
//* 1, break, 2 => `onStart(1); onStop(1); onStart(2); onStop(2)`;
//* 1, 2 => like above + `onChange(1, 2)`;
//* 1, 3 => like above (change 2 to 3) + `onJump(1, 3)`;

)

//Play / Stop
q.player.play
q.player.stop


//#### UI shortcuts
//* `Space`   play/pause
//* `-`       zoom in
//* `+`       zoom out
//* `s`       zoom to current segment
//* `a`       zoom to 100%
//* `f`       zoom & follow current segment/