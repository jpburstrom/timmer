(
Pbindef(\bandy_harmonic,
    \instrument, \bandyHit,
    \midinote, Prand([43, 45], inf).trace,
    \preamp, 4,
    \phase, 0.16,
    \harmonic, Pseq([1, Pxrand((2..6), 4)], inf).trace,
    \legato, 1,
    \group, q.tree.syngrp,
    \delayOffset, q.settings.rtlatency,
    \dur, Pseq([4, Prand([0.125, 0.25], 4)], inf)
).play
)
Pdef(\bandy_harmonic).stop
(
Pbindef(\bandy_harmonic2,
    \instrument, \bandy,
    \note, Pseq("gggg<<c".asMML, inf).trace,
    \octave, 3,
    \preamp, 4,
    \phase, 0.16,
    \legato, 1.5,
    \group, q.tree.syngrp,
    \delayOffset, q.settings.rtlatency,
    \dur, 0.25
).play(quant:1)
)
(
Pbindef(\bandy_harmonic3,
    \instrument, \bandy,
    \note, Pseq("aaaa<<cc".asMML, inf).trace,
    \octave, 3,
    \preamp, 5,
    \phase, 0.53,
    \legato, 1.68,
    \group, q.tree.syngrp,
    \delayOffset, q.settings.rtlatency,
    \dur, 0.25
).play(quant:1)
)
PdefAllGui()
