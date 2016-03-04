//# Template for songs ###

//## Initialize ###
(
"lib/init".import;
q.player.actionLabels = #[phrase, part];
q.player.tickLabel = \phrase;
q.player.loadData("04");
//q.player.extractFeatures;
q.playerui.connect(q.player);
q.markov = "lib/protos/markov-trainer".import;
q.markov.setBounds(q.player.data.lookup.part[2], q.player.data.lookup.part[3] - 1);
q.markov.connect(q.player);
q.markov.initChain;
)

(
//## Train our markov chain ##
//TODO: more training
q.markov.train;

)
2

q.player.play
q.player.currentEvent
q.player.stop;

(
//## Patterns #######

//This sets a pattern used to modify the base player pattern.
q.player.setPtn(Pbind(
	\amp, 1
));

//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(
	Plazy({
		var part = ~data.lookup.part;
        var mk = MarkovSet(q.markov.markovSet);
		Pseq([
			//First phrase is always the same
			0,
			//Part 0 have randomized phrases
			Pseq(Array.series(part[1]-1, 1).scramble),
			//Part 1 is sequential
			Pseries(part[1], 1, part[2]-part[1]),
			//TODO: How long will this go on? How should we transition?
            Pfin((part[3] - part[2]) + 1, p {
                var x=part[2];
                loop {
                    x.yield;
                    x = mk.next(x);
                }
            }),
			//Part 3 is random, and plays at least n-1 phrases
			Pseq((part[3] .. ~data.phrase.size - 2).scramble),
            //FIXME: last phrase is looping. why?
			Pif(Pfunc{ 0.5.coin }, q.player.data.phrase.size - 1, nil)


		]);
	})
)
)

//## Callbacks ####
(
//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar
q.player.onReady = {
};
)

q.player.actions.part.onStart = { |ev, x| "PART %".format("ABCD"[x]).debug }


q.player.play
q.player.stop
