//Anything outside Req.load statements are always run on reload
var ev = (foo:1.0.rand);

Req.load(initFunc: { |cleanup|
	cleanup.addFunc { "cleaning up reqtest2".postln; };
	"running main Req in reqtest2".postln;
	10.rrand(20);
});


Req.load(initFunc: { |cleanup|
	cleanup.addFunc { "hash test".postln; };
	"running #foo Req in reqtest2".postln;
	"hash test successful: %".format(~foo).postln;
}.inEnvir(ev), key:\foo);


Req.load(nil, {
	"loading".postln;
	(maxi: 23)
}, { |x|
	x.maxi = x.maxi.rand;
	x
}, \filter);

//Circular dep test
Req.load(['req tests#circular'], {"something".postln}, nil, \circular, true);
Req.load(nil, {"something".postln}, nil, \circular2);
