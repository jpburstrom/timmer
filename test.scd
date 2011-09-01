//Some ideas
//Load the tree data
~swed = "data/swed019w.txt".loadRelative[0] // The file is just an array, yes 
//smaller and smaller numbers
~le = ~swed.collect {|i, o| ~swed.size - o / ~swed.size } * 0.4

//Annoying test with durations
Pbind(\dur, Pseq(~swed) * Pseq(~le), \note, Pseq((~swed * 12 + 0.5).floor)).play
