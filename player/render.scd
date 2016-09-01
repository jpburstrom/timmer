var songlist = #[1,2,3,4,8,9];
var current;
var songs;
// ~songs.do(_.free);
songs = ~songs = ();
songlist.do { |song|
    q = ();
    song.asStringToBase(10, 2).import;
    songs[song] = q.player;
    songs[song].bounce;

};

