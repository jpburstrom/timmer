(
"lib/init".import;
q.player.actionLabels = #[onset, region];
q.player.loadData("01");
)
//Connect UI to player
q.playerui.connect(q.player);

//
q.player.setIterator(Pseries(0, 100));
q.player.next(())

p.setNextPos(2);
p.play;
p.stop;

q.player.trace = false
q.player.actionLabels

q.player.actions.region.onStart = { |...args| args.postln }
q.player.actions.region.onStop = { |...args| ("stop" ++ args).postln }


50.midicps
q.player.postGroup.register(true)
Ndef(\test, {
    var snd = In.ar(0, 2);
    var freq = 50.midicps;
    snd = BPF.ar(snd, freq, 0.1);
    snd * SinOsc.ar(0.600*freq, mul:LFNoise2.kr(1).range(0,1));

}).parentGroup_(q.player.postGroup)

Ndef(\test).end


(
fork {
var x = Pseries().asStream;
)
x.prev
Pseries(0, 2).asStream.nextN(10)

x = Pseries().asStream;
x.prev

p.next(())

p.nextPos