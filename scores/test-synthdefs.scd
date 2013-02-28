(
var sdfs = {









};
var ev = (
    song: \synthdefTest,
    synthdefs: sdfs
);
"lib/init.scd".loadRelative[0].(ev)
)

Synthdef(\test, {
    In.ar(0)

    ReplaceOut.ar(bus, snd)
})

(
// the basic wrapper
~makeEffect = {| name, func, lags, numChannels = 2, variants |

        SynthDef(name, {| i_bus = 0, gate = 1, wet = 1, fadeTime = 2|
                var in, out, env, lfo;
                in = In.ar(i_bus, numChannels);
                env = EnvGen.kr(Env.asr(fadeTime, 1, fadeTime, curve:\cub), gate, doneAction:2); // fade in the effect

        // call the wrapped function. The in and env arguments are passed to the function
        // as the first two arguments (prependArgs).
        // Any other arguments of the wrapped function will be Controls.
        out = SynthDef.wrap(func, lags, [in, env]);

        XOut.ar(i_bus, wet * env, out);
    }, [0, 0, 0.1, 0], nil, variants ).add;

};
)

~makeEffect.(\test, { arg in, env, freq=200;
    SinOsc.ar(freq, 0, 0.1) },
    [2],
    1,
    (foo: [freq: 400])
)

