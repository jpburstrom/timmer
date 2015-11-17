(
x.free;
x = {
    var freq = 80;
    MembraneCircle.ar(Impulse.ar(1), freq / 8025.324089, );
}.play

)
(
SynthDef(\membrane, { arg amp = 1, freq=440, loss=0.9, outbus;
    var snd, tension = (freq / 8025.324089).min(0.45).lag(0.01); // Approximate safe frequency
    loss = loss.linlin(0, 1, 0.99, 0.9999999);
    snd = MembraneCircle.ar(SoundIn.ar([0,1]), tension, Lag.kr(loss, 1), amp);
    EnvGate();
    Out.ar(outbus, snd);
}).add;
)

(

Pmono(
    \membrane,
    \midinote, 75,
    \detune, Pwhite(-0.5, 0),
    \dur, 1,
    \loss, Pwhite(0.8, 1)
).play

)

Trig
s.meter
{EnvGen.ar(Env.perc(0, 0.01))}.play

Trig

1.linlin