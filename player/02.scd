(
"lib/init".import;
q.player.actionLabels = #[phrase, beat];
q.player.tickLabel = \phrase;
q.player.loadData("02");
q.player2 = q.player.clone;
q.player2.tickLabel = \beat;
q.player2.prepareScore;
q.player2.setPtn(Pbind(\tempo, Pfunc { |ev| var t = ~data.beat[ev.beat][2]; q.player.t.delay.set(\delayTime, t * 0.5); t; }, \dur, 1, \type, \rest));
// q.player.parPtn = Pbind(\adjustDur, Pfunc { |ev| ev.dur = ev.dur * 0.5}) <> q.player2.asPattern
)
(
q.playerui = "lib/protos/score-player-gui".import;
q.playerui.connect(q.player)
)

q.player.setIterator(Pseries());

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
q.player.setPtn(Pbind(\fadetime, 0.01, \startPos, Pkey(\startPos) - 0.15));

q.player.actions.phrase

q.player.onReady = {

	"start".postln;
	q.player2.play;

	~t.delay = {
		var snd = In.ar(0, 2);
		DelayC.ar(snd, 1, \delayTime.kr(0.5, 0.05), 0.2);
	}.play(target:~t.postGroup);
};


)


q.player.trace = false;
q.player.play
q.player.stop

q.player2.play


q.player2.stop
1
q.player.data.beat