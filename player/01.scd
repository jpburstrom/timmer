(
"lib/init".import;
q.player.actionLabels = #[onset, region];
q.player.loadData("01");
q.player.data[\score][0];
)
q.playerui.connect(q.player);

p.play;
p.stop;

q.player.data.region

q.player.data[\score][0]

q.player.actions.region.start = { |...args| args.postln }
	