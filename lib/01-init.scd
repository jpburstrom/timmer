// Main sets main project dir, then we do this dance.

~dir.data = ~dir.project ++ "data/";
~dir.samples = ~dir.project ++ "samples/";

//Load all asset files, put them in ~q 
(~dir.data ++ "*").pathMatch.do { |p| ~q.data[p.basename.splitext[0].asSymbol] = p.load } ;
//Were assuming samples/subdir/file.wav, replacing spaces & hyphens for underscore (to work as symbol)
(~dir.samples ++ "*").pathMatch.do( { |p|
	var sub = p.basename.splitext[0].asSymbol;
	~q.samples[sub] = ();
	(p ++ "*").pathMatch.do( { |q|
		~q.samples[sub][q.basename.splitext[0].tr($ , $_).tr($-, $_).asSymbol] = SoundFile(q);
	})
});

"*******INITED*********".postln;
"Hurra"

