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
            "PLAYING".postln;
        } {
            "STOPPED".postln;
        }

    };

    ~macros[\1] = nil;
    ~macros[\2] = { |play, q|
        play.asString.honk;
    };
}

