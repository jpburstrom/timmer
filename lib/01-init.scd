//Some ideas
//Load the tree data
~init = Proto({
	
	~prep = {
		~projectDir = "/Volumes/Mega/projects/timmer/kod/sc/";
		~swed = (~projectDir ++ "data/swed019w.txt").loadPaths[0]; // The file 
		~swed
	}
	
	
	
}) => BP(\init);

~g = BP(\init).v

~g.swed

//is just an array, yes 
//smaller and smaller numbers
~le = ~swed.collect {|i, o| ~swed.size - o / ~swed.size } * 0.4

//Annoying test with durations
Pbind(\dur, Pseq(~swed) * Pseq(~le), \note, Pseq((~swed * 12 + 0.5).floor)).play


String

"*".pathMatch
