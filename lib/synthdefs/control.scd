q.makeDefs (\ctl,
    [
        //Borrowed from ddwSynths, ddwChucklib quark
        \ctlPoint,
        {
            arg snd, value, sustain, curve;
            EnvGen.kr(Env([snd, value], [sustain], curve), doneAction: 2);
        }
    ],
    [
        \ctlRange,
        {
            arg snd, min=0, max=1, step=0;
            ControlSpec(min, max, \lin, step).map(snd);
        }
    ],
    [
        //Borrowed from ddwSynths, ddwChucklib quark
        \ctlEnv,
        {
            // this def plays an arbitrary envelope on the bus
            arg snd, levelScale = 1, levelBias = 0, sustain = 1, connect = 1;
            var	env = \env.kr(0 ! 40);	// enough for 10 breakpoints
            // env[0] = Select.kr(connect > 0, [env[0], snd]);
            EnvGen.kr(env, 1, levelScale, levelBias, sustain, doneAction: 2)
        },
        nil,
        (outClass: XOut)
    ],
    [
        \lfoSin,
        {
            arg snd, freq=1, phase=0, min=0, max=1;
            LFCub.kr(freq, phase).range(min, max);
        },
        nil,
        (outClass: XOut)
    ],
    [
        \lfoPulse,
        {
            arg snd, freq=1, phase=0, width=0.5, min=0, max=1;
            LFPulse.kr(freq, phase, width, max-min, min);
        },
        nil,
        (outClass: XOut)
    ],
    [
        \lfoSaw,
        {
            arg snd, freq=1, phase=0, min=0, max=1;
            LFSaw.kr(freq, phase).range(min, max);
        },
        nil,
        (outClass: XOut)
    ],
    [
        \lfoTri,
        {
            arg snd, freq=1, phase=0, min=0, max=1;
            LFTri.kr(freq, phase).range(min, max);
        },
        nil,
        (outClass: XOut)
    ],



);

   /*

SynthDef(\ctlPoint, { |outbus, value, time, curve|
	var	start = In.kr(outbus, 1);
	ReplaceOut.kr(outbus, EnvGen.kr(Env([start, value], [time], curve), doneAction: 2));
}).perform(Library.at(\ddwGlobal, \storeMethod), \ddwSynths);

// this def plays an arbitrary envelope on the bus
// to avoid discontinuity, the envelope's init value is replaced
// with the bus's value if connect>0
SynthDef(\ctlEnv, { |outbus, levelScale = 1, levelBias = 0, time = 1, connect = 1|
	var	env = \env.kr(0 ! 40);	// enough for 10 breakpoints
	env[0] = Select.kr(connect > 0, [env[0], In.kr(outbus, 1)]);
	ReplaceOut.kr(outbus, EnvGen.kr(env, 1, levelScale, levelBias, time, doneAction: 2));
}).perform(Library.at(\ddwGlobal, \storeMethod), \ddwSynths);



t = Bus.control(s)
t.scope
z = Bus.control(s)
z.scope



*/
