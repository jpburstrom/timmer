Ndef.clear;
q.settings.rtlatency = q.settings.latencies.sum;
Spec.add(\delayAdjustment, [0, 1024, \lin, 1]);
SynthDef(\bandy, { |freq=100, delayOffset=0.0094, phase=0.8|
    var in = SoundIn.ar(0);
    var period = freq.reciprocal;

    //Calculate minimum delay for certain frequency
    var delay = (((delayOffset - (period * phase)) * freq).ceil * period) + ( period * phase);
    in = BPF.ar(in * \preamp.kr(0.0), freq, \rq.kr(0.0289));
    in = DelayC.ar(in, 0.1, delay);
    //TODO: remove this, make a global final HPF
    4.do {
        in = HPF.ar(in, 50)
    };
    Out.ar(\out.kr, in);
}).add;

q.tree.on(\groups, {

    var calcDelay = { |freq|
        var late = q.settings.rtlatency;
        var del = (freq).reciprocal;
        //calculate closest multiple of freq, and delay with that, adjusted for latency
        (((late / del).ceil * del) - late);

    };
    "Adding synths".postln;
    ~synths = ();
    q.cvs.delayAdjustment = IdentityDictionary();
    q.cvs.phase = IdentityDictionary();

    q.settings.pitches.do { |i|
        var sym = i.asSymbol;
        //q.cvs.delayAdjustment[sym] = CV(\delayAdjustment, calcDelay.(i.midicps));
        q.cvs.phase[sym] = CV(\unipolar, 0.8);

        ~synths[sym] = Synth(\bandy,
            [\freq, i.midicps, \out, 0, \delayOffset, q.settings.rtlatency], q.tree.syngrp);
        ~synths[sym].setControls([
            preamp: q.conds.preamp[sym],
            phase: q.cvs.phase[sym],

 //           delayAdjustment: q.cvs.delayAdjustment[sym]
        ]);


    };
});



/*
q.settings.pitches.do { |i| Ndef(i.asSymbol).set(\rq, 0.03) }
NdefMixer(s)
s.options.hardwareBufferSize = 512
*/

