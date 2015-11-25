(
//This should only load the second Req.load statement
Req.load(['reqtest2#foo'], { |rt2, cleanup|
	rt2.debug("rt2");
    cleanup.addFunc( { "hello".postln });
	"return value"
}, (_+1), reload:true);
);

(
//What happens with a circular reference?
Req.load(['reqtest2#circular'], { |rt2, cleanup|
	rt2.debug("rt2");
    cleanup.addFunc( { "hello".postln });
	"return value"
}, (_+1), \circular, reload:true);
);

(
//Let's subdirectory
Req.load(['req/test1'], { |rt2, cleanup|
	rt2.debug("test1");
    cleanup.addFunc( { "hello".postln });
	"return value"
}, (_+1), \circular2, reload:true);
);


(
//sub-dependency test
Req.load(['req/test1#bob'], { |rt2, cleanup|
	rt2.debug("test1");
    cleanup.addFunc( { "hello".postln });
	"return value"
}, (_+1), \subdep, reload:false);
);


(
//sub-dependency test
Req.load(['req tests#update2'], { |rt2, cleanup|
	rt2.postln;
	"loading if dependency is updated".postln;
}, nil, \update1, true);

Req.load(['req tests#update3'], { |rt2, cleanup|
	var v = 1.0.rand.debug("todays random value");
	rt2.debug("value from third");
	"having a dependant".postln;
	v
}, nil, \update2, reload:true);


Req.load(nil, { |rt2, cleanup|
	var v = 1.0.rand.debug("todays third random value");
	"having a dependant as dependant".postln;
	v
}, nil, \update3, reload:true);

)
/*
Req.get.circularCheck
*/
