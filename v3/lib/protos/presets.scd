Proto({
    ~items = nil;
    ~presets = ();
    ~current = 0;
    ~target = 0;

    ~setItems = { arg items;
        ~items = items;
    };

    ~setPresetContainer = { arg c;
        ~presets = c;
    };

    ~addPreset = { arg index;
        ~presets[index] = ~items.collect(_.value);
    };

    ~removePreset = { arg index;
        ~presets[index] = nil;
    };

    ~setCurrent = { |key|
        ~current = key;
    };

    ~setTarget = { |key|
        ~target = key;
    };

    ~morph = { |amt, keys, output(true)|
        var vals;
        if (keys.isNil) {
            vals = ~presets[~current].blend(~presets[~target], amt);
        } {
            vals = ~presets[~current].select({ |v,k| keys.includes(k) })
            .blend(~presets[~target], amt, false);
        };
        //if output == false, only return values
        if (output) {
            vals.keysValuesDo { |k, v| ~items[k].value = v; };
        };
        vals;
    };
});
