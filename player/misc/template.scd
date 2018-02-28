//# Template for songs ###

//## Initialize ###
(
"lib/init".import;
q.player.actionLabels = #[onset, region];
q.player.tickLabel = \onset;
q.player.loadData("01");
//q.player.extractFeatures;
q.playerui.connect(q.player)
)
(
//## Patterns #######

//This sets a pattern used to modify the base player pattern.
q.player.setPtn(Pbind());

//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(Pseries());
)

//## Callbacks ####
(
//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar
q.player.onReady = {
};
)

q.player.play
q.player.stop