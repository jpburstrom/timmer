//Set routing
var createRouting = { |r, sym|
    [r, sym].postln;
    [\lfo, \noise, \pedal, \amp].do { |x|
        [\pitch, \delay, \rev, \amp].do({ |y|
            r[\routing, sym, x, y] = 0;
        });

    };
    [\pedal, \amp].do { |x|
        [\lfoSpeed, \lfoDepth, \noiseSpeed, \noiseDepth].do { |y|
            r[\routing, sym, x, y] = 0;
        }
    };
};

q.make {
    ~storage[\routing] ?? {
        q.settings.pitches.do { |x| createRouting.(~storage, x.asSymbol) };
    }
};

q.storage[\routing] = nil
