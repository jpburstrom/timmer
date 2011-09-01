(
//********
// LOADING
//********
//~dir: directories, ~q: assets 
Environment.push((dir: (), q: (data: (), samples: ())));
//Set a few globals 
~dir = Event.make({
	~project = "/Volumes/Mega/projects/timmer/kod/sc/";
	~lib = ~project ++ "lib/";
	~data = ~project ++ "data/";
	~samples = ~project ++ "samples/"
});

//Load all asset files, put them in ~q 
(~dir.data ++ "*").pathMatch.do { |p| ~q.data[p.basename.splitext[0].asSymbol] = p.load } 
//Were assuming samples/subdir/file.wav, replacing spaces & hyphens for underscore (to work as symbol)
(~dir.samples ++ "*").pathMatch.do( { |p|
	var sub = p.basename.splitext[0].asSymbol;
	~q.samples[sub] = ();
	(p ++ "*").pathMatch.do( { |q|
		~q.samples[sub][q.basename.splitext[0].tr($ , $_).tr($-, $_).asSymbol] = SoundFile(q);
	})
});

//is just an array, yes 
//smaller and smaller numbers
~le = ~swed.collect {|i, o| ~swed.size - o / ~swed.size } * 0.4

//Annoying test with durations
Pbind(\dur, Pseq(~swed) * Pseq(~le), \note, Pseq((~swed * 12 + 0.5).floor)).play


String

"*".pathMatch
