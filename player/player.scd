var songlist = #[1,2,3,4,7,8,9,10];
var current;
var songs;
// ~songs.do(_.free);

//Test: Keep track of position in song
var segmentController = Proto({
    ~segmentCounter = songlist.collectAs( { |x| x.asStringToBase(10,2)->0 }, Dictionary);
    ~update = { |player, what, args|
        if (what == \segment) {
            ~segmentCounter[player.song] = ~segmentCounter[player.song] + 1;
        };
    };
});

~segCtrl = segmentController;

songs = ~songs = ();
songlist.do { |song|
    var player;
    q = ();
    //2 -> "02"
    song.asStringToBase(10, 2).import;
    player = q.player;

    player.addDependant(segmentController);

    ~songs[song] = player;
};

ListView().items_(songlist.collect(_.asStringToBase(10, 2))).selectionMode_(\single).action_({ |view|

    current.stop;
    view.selection.postln;
    current = songs[songlist[view.selection[0]]];

    // current.play(0, TempoClock.new);
    current.play

}).front

