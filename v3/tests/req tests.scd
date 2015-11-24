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
