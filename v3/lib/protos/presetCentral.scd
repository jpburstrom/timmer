Proto({
	//Dictionary with CVs or similar
    ~items = nil;
    //Dictionary with preset values
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

    //Get preset, update items by default
    //Optionally pass keys to select subset of items
    ~getPreset = { arg index, keys,update(true);
        var idx = index ?? ~current;
        var vals = ~presets[idx];
        if (keys.notNil) { vals = vals.select { |v,k| keys.includes(k) } };
        ~current = idx; //Should we set current?
        vals.keysValuesDo { |k,v| ~items[k] !? (_.value = v); };
    };

    //Morph ~current with ~target, update items by default
    //Optionally pass keys to select subset of items
    ~morph = { |amt, keys, update(true)|
        var vals;
        if (keys.isNil) {
            vals = ~presets[~current].blend(~presets[~target], amt);
        } {
            vals = ~presets[~current].select({ |v,k| keys.includes(k) })
            .blend(~presets[~target], amt, false);
        };
        //if update == false, only return values
        if (update) {
			vals.keys.do { |k| ~items[k] !? (_.value = vals[k].value); };
        };
        vals;
    };
});
