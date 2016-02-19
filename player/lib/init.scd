q.do(_.free);
q.clear;
"[0-9]*.scd".resolveRelative.pathMatch.do(_.load);
q.player = "protos/score-player".import;
q.playerui = "protos/score-player-gui".import;



