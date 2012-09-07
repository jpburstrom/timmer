b = Buffer.read(s, "/Volumes/HD2/projects/timmer/render/to SC/single-note-arco.wav");
(

~test = Pbind(
		\instrument, 'timmer.grainMono',
		\bufnum, b,
		\type, \on,
		\delta, Pxrand([2,4,8].reciprocal, inf),
		\pan, Pxrand([0], inf), 
		\bufRate, Pbrown(0,11).midiratio,
		\startPos, Pwhite(0, 1.0),
		\amp,1,
		\attack, 1,
		\out, 0,
);

Pdef(\test, ~test).play
)

(

~test2 = Pbind(
		\instrument, 'timmer.grainMono',
		\bufnum, b,
		\type, \on,
		\delta, Pxrand([0.2, 0.3], inf),
		\pan, Pxrand([0], inf), 
		\bufRate, Pwrand(([-12,-24,[2,-21],[-2,7]] + 7).midiratio, [5, 1, 5].normalizeSum, inf),
		\startPos, Pwhite(0, 1.0),
		\amp, 1,
		\attack, 0.9,
		\out, 0,
);

Pdef(\test2, ~test2).play
Pdef(\test2, ~test2).stop
)

