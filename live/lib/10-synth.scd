Ndef.clear;
q.settings.rtlatency = q.settings.latencies.sum;

//ADD SYNTHDEFS
SynthDef(\bandy, { |freq=100, delayOffset=0.0094, phase=0.8|
    var in = SoundIn.ar(0);
    var period = freq.reciprocal;
    //Calculate "phase" for frequency
    var delay = ((period - delayOffset) % period) + (period * phase);

    in = BPF.ar(in * \preamp.kr(0.0), freq, \rq.kr(0.0289));
    in = DelayC.ar(in, 0.1, delay + \delayMod.ar(0));
    in = in * EnvGen.kr(Env.cutoff(0.0), \gate.kr(1), doneAction:2);
   // in = (SinOsc.ar(freq) * 0.1);
    Out.ar(\out.kr, in);
}).add;

SynthDef(\bandyHit, { |freq=100, delayOffset=0.0094, phase=0.8|
    var in = SoundIn.ar(0) + Decay.ar(Impulse.ar(0), 0.001);
    var period = freq.reciprocal;

    //Calculate "phase" for frequency
    var delay = (((delayOffset - (period * phase)) * freq).ceil * period) + ( period * phase);
    in = BPF.ar(in * \preamp.kr(0.0), freq, \rq.kr(0.0289));
    in = DelayC.ar(in, 0.1, delay + \delayMod.ar(0));
    in = in * EnvGen.kr(Env.cutoff(0.0), \gate.kr(1), doneAction:2);
    Out.ar(\out.kr, in);
}).add;


SynthDef(\finalHPF, { |freq=45, out=0|
    var snd = In.ar(out);
    10.do {
        snd = HPF.ar(snd, freq);
    };
    ReplaceOut.ar(out, snd);
}).add;

//After setting groups, please add synths
q.tree.on(\groups, {

    "Adding synths".postln;
    ~synths = ();
    ~fx = ();

    q.make {
        ~createBandySynth = e { |i|
            var sym = i.asSymbol;

            q.tree.synths[sym] = Synth(\bandy,
                [\freq, i.midicps, \out, 0, \delayOffset, q.settings.rtlatency], q.tree.syngrp);
            q.tree.synths[sym].setControls([
                preamp: q.storage[\cvs, \preamp, sym],
                phase: q.storage[\cvs, \phase, sym],
            ]);
        };

        ~releaseBandySynth = e { |i|
            q.tree.synths[i.asSymbol].release;
        };
    };

    //Important: high pass filter
    ~fx[\finalHPF] = Synth(\finalHPF, [\freq, 45], q.tree.mstfxgrp);
});

/*
q.settings.pitches.do { |i| Ndef(i.asSymbol).set(\rq, 0.03) }
NdefMixer(s)
s.options.hardwareBufferSize = 512
*/
