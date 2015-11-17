q.make {
    ~macros ?? {
        ~macros = Proto({
            ~exists = { |i|
                currentEnvironment[i.asSymbol].isFunction;
            };

            ~run = { |i, play|
                //TODO: pass CVs/MKtlElements to function
                currentEnvironment[i.asSymbol].value(play, q);
            }

        }).putAction_({ |key, value, p|
            p.changed(\put, key.asInt, value);
        });
    };

    ~macros[\0] = { |play, q|
        if (play) {
            Ndef(\test, {
                var snd = SoundIn.ar(1);
                snd = FreqShift.ar(HPF.ar(snd, 500), -500);
                snd = DelayC.ar(snd, 5, LFNoise2.kr(0.01).exprange(0.2, 5)) * 4;
            }).fadeTime_(3).play
        } {
            Ndef(\test).stop
        }

    };

    ~macros[\1] = nil;
    ~macros[\2] = { |play, q|
        play.asString.honk;
    };
}

