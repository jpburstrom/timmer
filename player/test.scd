(
"lib/init".import;
q.player.actionLabels = #[onset, region];
q.player.loadData("01");
q.player.extractFeatures;
q.fxbus = Bus.audio(s, 2);

)
(
q.player.setIterator(p { |ev|
	var i = 0;
	var radius = 0.1;
	loop {
		i = i + 1;
		ev = ~data.kdTree.radiusSearch(~data.featureClump[i], radius).choose.label.yield
	}
});
)

(
q.player.onReady = {
	{ var snd = In.ar(q.fxbus, 2); FreqShift.ar(snd, -100) }.play(target: q.player.postGroup);
};
q.player.setPtn(Pbind(
	\amt, Pseg([0.5, 0], 25, \sin), //Pif(Pwhite(hi:0.6).coin, Pwhite(0, 0.35), Pseg([0,0.4,0], 20, \sin, inf)),
	\dur, Fdef(\changePatternEndTime).(\amt),
	\out, Pif(Pkey(\dur) < 0.35, q.fxbus, 0)
));
)
q.player.play
q.player.trace = false
q.player.play
q.player.stop
q.player.bufnum
q.player.modPtn.out = Pseq([0,0], inf).trace

x = (dur:10).play
x.free

q.player.setPtn());

q.player.data.onset.reject(_[1]>1).collect(_[1]).plot
q.player.data
