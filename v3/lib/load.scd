Proto({
	~reloaded = Set();
	~loaded = ();

	~load = { |func ... args|
		func.(*args.collect { |key|
			if (~loaded[key].isNil or: { ~reloaded.includes[key].not }) {
				~loaded[key] = "%.scd".format(key).loadRelative[0];
				~reloaded.add(key);
			};
			~loaded[key].value;
		});
	};

	~reload = { |func ... args|
		~reloaded.clear;
		~load.value(func, *args);
	}
});

Require(#[array, of, deps], { |array, of, deps, ev|
});