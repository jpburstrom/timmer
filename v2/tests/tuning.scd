t = Tuning.new([1, (4/3).pow(5) * 0.25, 9/8, (4/3).pow(3) * 0.5,
    5/4, 4/3, 45/32, 3/2,
    (4/3).pow(4) * 0.5, 27/16, 16/9, 15/8].ratiomidi, 2, 'doublebass_D')

)

//root:
"G1".namemidi + Scale.chromatic(t).semitones

(scale: Scale.chromatic(t), degree: [0,3]+8, instrument:\sine, \amp: 0.6, \root:, dur:2).play.freq.reverse.reduce('/')
3/2

c = (0..30).collect({ |x| Scale.chromatic(t).degreeToFreq(x, 38.midicps, 0) })

c.cpsmidi.clump(5)[1]

c[4] / c[0]
5/4
Scale.chromatic(\just).ratios


t = CV()
t.gui
x = Synth(\bandy, [\freq, "G1".namecps * 4, \out, 0, \delayOffset, q.settings.rtlatency], q.settings.syngrp);



q.settings.rtlatency