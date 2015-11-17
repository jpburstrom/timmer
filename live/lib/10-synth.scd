Ndef.clear;

//----------START MAKING SYNTHDEFS----------------

SynthDef(\bandy, { |freq=100, delayOffset=0.0094, phase=0.8|
    var
    in = SoundIn.ar(1),
    period = freq.reciprocal,
    //Calculate "phase" for frequency, before modulation happens
    totalDelay = ((period - delayOffset) % period) + (period * phase);

    //Freq modulation
    freq = freq * 2.pow((\freqAdjust.kr(0) + \freqMod.kr(0)));

    //Delay modulation (incl phase modulation)
    //
    totalDelay = totalDelay + \delay.kr(0, 0.1) + \delayMod.kr(0)
    + \phaseMod.ar.range(0, period);

    in = BPF.ar(in * \amp.kr(0.0), freq, \rq.kr(0.0289));

    //DEBUG
    //Patch 0 -> 0 fysiskt på ljudkortet
    //scope ch 64 och 65
    OffsetOut.ar(0, in);
    OffsetOut.ar(64, [in, SoundIn.ar(0)]);

    //DEBUG
    //test tones
    //Out.ar(\out.kr, SinOsc.ar(freq) * 0.05);

    //

    // Max delay time 1 sec + 20.reciprocal
    in = DelayC.ar(in, 1.05, totalDelay);

    //TODO: fix env
    in = in * EnvGen.kr(Env.cutoff(0.0), \gate.kr(1), doneAction:2);

    Out.ar(\out.kr, in);
}).add;

//-------------LFOs---------------------

[
    lfoSin: SinOsc,
    lfoNoise: LFDNoise3
].pairsDo { |name, class|
    SynthDef(name, {
        var snd = class.kr(\freq.kr + 2.pow(\freqMod.kr(0)), mul: \depth.kr * \depthMod.kr);
        Out.kr(\out.kr, snd);
    }).add;
};


//--------------------------------------

SynthDef(\finalHPF, { |freq=45, out=0|
    var snd = In.ar(out);
    10.do {
        snd = HPF.ar(snd, freq);
    };
    ReplaceOut.ar(out, snd);
}).add;

//----------END SYNTHDEFS---------------

//After setting groups, please add synths
q.tree.on(\groups, {

    var env = currentEnvironment;

    //helper functions + mappings
    var f = Proto({
        ~getCV =  { |...args|
            q.storage.atPath(#[cvs] ++ args)
        };

        ~mapAmp =  { |sym|
            var preamp = ~getCV.(\preamp, sym),
                amp = ~getCV.(\amp, sym),
                gAmp = ~getCV.(\global, \amp);
            //multiply 3 cvs to get final amp value
            [[preamp, amp, gAmp], preamp * amp * gAmp];
        };

        ~mapDelay =  { |sym|
            var gDelay = ~getCV.(\global, \delay),
                lDelay = ~getCV.(\delay, sym),
                out;
            //gDelay is bipolar,
            //if < 0, multiply with local delay
            //otherwise add to local
            if (gDelay.value <= 0) {
                out = gDelay.abs * lDelay
            } {
                out = (gDelay + lDelay)
                //clip to maximum of lDelay and gDelay
                .min(lDelay.spec.clipHi.max(gDelay.spec.clipHi))
            };

            [[gDelay, lDelay], out]
        };

        ~maybeSendProxy = { |node|
            //nodeID is set to nil on .release
            node.objects[0].nodeID.isNil.if {
                node.send;
            };
        };

        ~createCtlProxy = { |source|
            NodeProxy.control(s, 1).prime(source)
            .group_(Group())
            .parentGroup_(q.tree.ctlgrp);
        };

    });

    //Get computed latency
    var latency = q.f.getLatency;

    //----------Add synths & LFOs-----------
    ~synths = ();
    ~lfo = [(), ()];
    ~fx = ();

    //Create proxies for all pitches
    q.settings.pitches.do { |i|
        var sym = i.asSymbol;

        //Prime synth
        ~synths[sym] = NodeProxy.audio(s, 1).prime(\bandy)
        .group_(Group()) //Group is needed for .setControls
        .parentGroup_(~syngrp)
        .set(\freq, i.midicps, \out, q.bus.bass,
            \delayOffset, latency)
        .setControls([
            freqAdjust: f.getCV(\global, \pitch),
            phase: f.getCV(\phase, sym),
            amp: f.mapAmp(sym),
            delay: f.mapDelay(sym),
        ]);


        //Prime LFO1
        ~lfo[0][sym] = f.createCtlProxy(\lfoSin).setControls([
            lfoSpeed: f.getCV(\global, \lfoSpeed),
            lfoDepth: f.getCV(\global, \lfoDepth)
        ]);




        //Prime noise LFO
        ~lfo[1][sym] = f.createCtlProxy(\lfoNoise).setControls([
            lfoSpeed: f.getCV(\global, \noiseSpeed),
            lfoDepth: f.getCV(\global, \noiseDepth)
        ])


    };


    //--------PostFX Reverb---------
    ~fx[\rev] = NodeProxy.audio(s, 1)
    .parentGroup_(~mstfxgrp)
    .source_({
        var snd = In.ar(\out.kr(0));
        snd = SelectX.ar(\amp.kr(0), [snd, JPverb.ar(snd, 10, 0, 2)]);
        ReplaceOut.ar(\out.kr(0), snd);
    })
    .bus_(q.bus.bass)
    .setControls([
        amp: f.getCV(\global, \rev)
    ]).play;

    //---------Important: high pass filter------------
    ~fx[\finalHPF] = Synth(\finalHPF, [\freq, 45], q.tree.mstfxgrp);

    //----------Playback functions---------//

    //.setControls needs to be called on a playing nodeproxy,
    //and will reset when node ends

    //q.tree.playSynth
    ~playSynth = e { |i|
        var sym = i.asSymbol;
        //Send because proxy is not playing
        //
        ~synths[sym].send.play;

    };

    //q.tree.stopSynth
    ~stopSynth = e { |i|
        //.release keeps the group alive
        ~synths[i.asSymbol].release;
    };

    ~lfoDest = [Set(), Set()];

    //------------Create LFOs-------------
    value {
        var createPlayLFOfor = { |index|
            e { |i, dest|
                var sym = i.asSymbol;
                var lfo = ~lfo[index][sym];
                f.maybeSendProxy(lfo);
                if (~lfoDest[index].includes(dest).not and: { ~synths[sym].group.notNil }) {
                    ~synths[sym].perform('<<>', lfo, dest);
                    ~lfoDest[index].add(dest);
                }

            }
        };

        var createStopLFOfor = { |index|
            e { |i, dest|
                var sym = i.asSymbol;
                if (~lfoDest[index].includes(dest)) {
                    ~synths[sym].set(dest, nil);
                    if (~lfoDest[index].remove(dest).size == 0) {
                        ~lfo[index][sym].release;
                    }
                }
            }
        };

        ~playLFO = createPlayLFOfor.(0);
        ~stopLFO = createStopLFOfor.(0);

        ~playNoise =  createPlayLFOfor.(1);
        ~stopNoise =  createStopLFOfor.(1);

    };


});

/*
q.settings.pitches.do { |i| Ndef(i.asSymbol).set(\rq, 0.03) }
NdefMixer(s)
s.options.hardwareBufferSize = 512
*/
