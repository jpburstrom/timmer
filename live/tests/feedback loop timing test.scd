{
    var in = SoundIn.ar(0);
    var sine = SinOsc.ar(65) * Decay.ar(Impulse.ar(0.5));
    Out.ar(32, [sine, in]);
    Out.ar(4, sine * 0.09);
    [DelayC.ar(sine, 0.2, 0.0276), in]
}.plot(0.83)

