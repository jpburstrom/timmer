var inserts = (
    compressor: { |snd, thresh=0.1, ratio=2, attack=0.01, release=0.1, amp=1|
        CompanderD.ar(snd, thresh, 1, ratio.reciprocal, attack, release, amp);
    },
    limiter: { |snd, level=1|
        Limiter.ar(snd, level);
    },
    safeLimiter: { |snd, level=1|
        snd = ReplaceBadValues.ar(snd);
        Limiter.ar(snd, level);
    },
    softclip: { |snd, pregain=1, amp=1|
        SoftClipAmp8.ar(snd, pregain, amp);
    },
    fixedDelay: { |snd, i_maxDelay=0.1, delay=0.01|
        snd = DelayN.ar(snd, i_maxDelay, delay);
    },
    zapper: { |snd|
        ReplaceBadValues.ar(snd);
    }
);

var sends = (
    jpverb: { |snd, time=4, damp=0.9, size=2, earlyDiff=0.707, amp=0.25|
        JPverb.ar(snd, time, damp, size, earlyDiff) * amp
    }
);

inserts.keysValuesDo { |name, def|

    (1..2).do { |ch|
        var tmpname = name;
        if (ch == 1) {
            tmpname = (name ++ "_mono").asSymbol;
        };
        SynthDef(tmpname, { |outbus|
            var snd = In.ar(outbus, ch);
            snd = SynthDef.wrap(def, prependArgs:[snd]);
            ReplaceOut.ar(outbus, snd);
        }).add;
    }
};

sends.keysValuesDo { |name, def|

    (1..2).do { |ch|
        var tmpname = name;
        if (ch == 1) {
            tmpname = (name ++ "_mono").asSymbol;
        };
        SynthDef(tmpname, { |inbus, outbus|
            var snd = In.ar(inbus, ch);
            snd = SynthDef.wrap(def, prependArgs:[snd]);
            Out.ar(outbus, snd);
        }).add;
    }
}



