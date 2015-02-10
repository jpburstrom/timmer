SynthDef(\sine, {
    var snd = SinOsc.ar(\freq.kr, 0, \amp.kr) * Linen.kr(\gate.kr(1), 0, 1, 1, 2);
    Out.ar(\out.kr(0), snd);
}).add;
(
Pdef(\testtone,
    Pbind(
        \instrument, \sine,
        \midinote, 36,
        \dur, 4,
        \legato, 1
    );
).play
);

Pdef(\testtone).stop

