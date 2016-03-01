(
"lib/init".import;
q.player.actionLabels = #[phrase, beat];
q.player.tickLabel = \phrase;
q.player.loadData("02");
q.player2 = q.player.clone;
q.player2.tickLabel = \beat;
q.player2.prepareScore;
q.player2.setPtn(Pbind(\instrument, \tick, \tempo, Pfunc { |ev| ~data.beat[ev.beat][2].postln }, \dur, 1, \type, Pwrand([\note, \rest], [1, 0], inf)));
// q.player.parPtn = Pbind(\adjustDur, Pfunc { |ev| ev.dur = ev.dur * 0.5}) <> q.player2.asPattern
)
(
q.playerui = "lib/protos/score-player-gui".import;
q.playerui.connect(q.player)
)
q.playerui.free
(
//Randomizing works a lot of the times, but not when
q.player.setIterator(Prout({
    var count = 0;
    var size = ~data.phrase.size;
    var prob = 1; //Random jump probability
    var nojump = [0, size-1]; //Indexes to always play
    while { count < size } {
        var i = count;
        if (prob.coin and: { nojump.includes(i).not } ) {
            "jump".postln;
            i = size.rand;
        };
        i.postln.yield;
        count = count + 1;
    }
}));
q.player.setPtn(Pbind(\fadetime, 0.01, \startPos, Pkey(\startPos) - 0.15))
)


q.player.setIterator(Pif(Pfunc { 0.9.coin }, Pseries(), Pseries()))

Pdefn(\asd, Pif(Pseries(0, 0.01).coin, Pdefn(\asd), Pseries()))

Pdefn(\asd).iter.nextN(100000).maxItem
y = Pbind(\degree, Pdefn(\asd), \dur, 0.1).play
y.stop
q.player.trace = false;
q.player.play
q.playerui.sfView.selection(0)
q.player2.stop

q.playerui.sfView.setSelectionColor(2, Color.fromHexString("eeeeee"))
q.playerui.sfView.setSelection(2, [4800000, 441000])


q.player.play; q.player2.play

x = { Ringz.ar(In.ar(0, 2), 504, 2) * 0.002 }.play(addAction:\addToTail)
x.free
Formlet

x = { SinOsc.ar(63) * 0.1 }.play
