var songlist = #[1,2,3,4,8,9];
var current;
var songs;
// ~songs.do(_.free);
songs = ~songs = ();
songlist.do { |song|
    q = ();
    //2 -> "02"
    song.asStringToBase(10, 2).import;
    ~songs[song] = q.player;
};

ListView().items_(songlist.collect(_.asStringToBase(10, 2))).selectionMode_(\single).action_({ |view|

    current.stop;
    view.selection.postln;
    current = songs[songlist[view.selection[0]]];

    // current.play(0, TempoClock.new);
    current.play

}).front
