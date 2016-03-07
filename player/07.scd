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
q.player.setPtn(Pbind());

q.player.setIterator(Pn(q.player.data.phrase.size - 1, 1))

//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(
    Plazy({
        var part = ~data.lookup.part;
        var repeatFirst = inf; //3.rrand(6);
        Pseq([
            0,
            Pxrand(Array.series(part[1]-1, 1), repeatFirst),
            part[1]
        ])
    })
);
)
q.player.setIterator(Pseries(0,1,1))
//## Callbacks ####
(
//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar
q.player.onReady = {

    //This should become our feedback synth
    ~t.comb = {
        var snd = In.ar(0, 2);
        var freq = [155, 206];

        //TODO: LocalIn => BPF => CombN => Limiter / fix => LocalOut
        //Amp adjusting freq, like early feedback experiments

        snd = snd + Mix(CombN.ar(BPF.ar(snd, freq, 0.05), 0.2, freq.reciprocal, 5, 2)).dup;

        ReplaceOut.ar(0, snd);
    }.play(target: ~t.postGroup)
};
)
q.player.trace = true
q.player.play
q.player.stop
q.player.readyForPlay