//# Template for songs ###

//## Initialize ###
(
"lib/init".import;
q.player.actionLabels = #[phrase, part];
q.player.tickLabel = \phrase;
q.player.loadData("04");
//q.player.extractFeatures;
q.playerui.connect(q.player)
)
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
		Pseq([
			//First phrase is always the same
			0,
			//Part 0 have randomized phrases
			Pseq(Array.series(part[1]-1, 1).scramble),
			//Part 1 is sequential
			Pseries(part[1], 1, part[2]-part[1]),
			//TODO: Markov chain?
			Pseq((part[2]..part[3]-1).scramble),
			//Part 3 is random, and plays at least n-1 phrases
			Pseq((part[3] .. ~data.phrase.size - 2).scramble),
			Pif(Pfunc{ 0.5.coin }, q.player.data.phrase.size - 1, nil)


		]);
	})
)
)
Prewrite
Pfsm2
m = MarkovSet([[1, [2,3]], [2, [4, 1]], [3, [1, 5]], [4, [2]]]);
x = 1;
100.collect{x = m.next(x)}.plot

Pbind(\dur, 0.1, \degree, p { var x=1; loop { x.yield; x = m.next(x);  } }).play

Quarks.gui
q.player.setIterator(Pseries(44))

//## Callbacks ####
(
//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar
q.player.onReady = {
};
)
Pnn

q.player.actions.part.onStart = { |ev, x| "PART %".format("ABCD"[x]).debug }


q.player.play
q.player.stop
P
var part = q.player.data.lookup.part; (part[2]..part[3]-1)
44-30

q.player.data.phrase.lastIndex - 1

(q.player.data.lookup.part[3]..q.player.data.phrase.lastIndex-1)



Array.series(q.player.data.lookup.part[1], 1).scramble