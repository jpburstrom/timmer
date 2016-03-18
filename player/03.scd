//# Template for songs ###

//## Initialize ###
(
var handClapPaths = "samples/handclaps/*.wav".resolveRelative;

"lib/init".import;
q.player.actionLabels = #[onset];
q.player.tickLabel = \onset;
q.player.loadData("03");
//q.player.extractFeatures;
q.playerui.connect(q.player);

)
(
q.player.onReady = {
    ~t.synth1 = {
        var freq= 84*2;
        var snd = BPF.ar(In.ar(0, 2) * 4, freq, LFNoise2.kr(0.1).range(0.002, 0.001)) * SinOsc.ar(LFNoise2.kr(0.2).exprange(120, 130));
        snd = CombC.ar(snd, 0.05, freq.reciprocal, 5);
        snd = DelayC.ar(snd, 0.1, LFNoise2.ar(0.2).range(0,0.01));
        snd
    }.play(target:~t.postGroup);
};

//## Patterns #######

//This sets a pattern used to modify the base player pattern.
q.player.setPtn(Pbind(
));


//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(Pseries());
)

q.player.play
q.player.stop

Ndef(\testtone).prime({ SinOscFB.ar(\freq.kr(84), \fb.kr(0.0) ).dup * \amp.kr(0.1) })

Ndef(\testtone).gui

