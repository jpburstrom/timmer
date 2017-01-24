var defaultFadeTime = 0.002;

Spec.add(\bufRate, \rate);
Spec.add(\dur, [0.001, 60, \exp]);
Spec.add(\delta, \dur);
Spec.add(\sustain, \dur);
Spec.add(\fqshift, [-20000, 20000]);
Spec.add(\startPos, [0, 1200]); //20 minutes
Spec.add(\attackStartPos, \startPos);
Spec.add(\legato, [0.001, 10, \exp]);
Spec.add(\outbus, \audiobus);
Spec.add(\sendAmp, \amp);
Spec.add(\midAmp, \amp);
Spec.add(\sideAmp, \amp);

//--pattern-specific specs--//
Spec.add(\quantAmt, \unipolar);
Spec.add(\varFactor, \unipolar);

//Load all files in synthdefs/
"synthdefs/*.scd".resolveRelative.loadPaths;


//Debug tick
SynthDef(\tick, {
    Line.kr(0, 1, 0.1, doneAction:2);
    Out.ar(\outbus.kr(0), Impulse.ar(0).dup);
}).add;


SynthDef(\sinewave, {
    var snd = SinOsc.ar(\freq.kr(440), 0, \amp.kr(0.1));
    snd = snd * EnvGen.ar(Env.asr(\attack.kr(0.01), \susLevel.kr(1), \release.kr(1)), \gate.kr(1), doneAction:2);
    Out.ar(\outbus.kr(0), Pan2.ar(snd, \pan.kr(0)));
}).add;