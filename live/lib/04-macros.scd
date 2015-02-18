q.make {
    ~macros ?? {
        ~macros = Proto({
            ~exists = { |i|
                currentEnvironment[i.asSymbol].isFunction;
            };

            ~run = { |i|
                currentEnvironment[i.asSymbol].value(q);
            }

        }).putAction_({ |key, value, p|
            p.changed(\put, key.asInt, value);
        });
    };

    ~macros[\0] = { |q|
        "Just testing".postln;
    };

    ~macros[\1] = nil;
    ~macros[\2] = { |q|
        "Another test".honk;
    };
}
