//A require for SC
Req {
	classvar instance;
	classvar <>alwaysReload;
	var <loaded, <reloaded;

	*new {
		^super.new.init;
	}

	*get {
		^( instance ?? { instance = this.new })  // If it doesn't exist yet, create it.
	}

	*load { |deps, fun, reload=false|
		^this.get.load(deps, fun, reload);
	}

	load { |deps, fun, reset=false|

		if (reset) {
			this.reloaded.clear;
		};

		if (deps.isFunction) {
			fun = deps;
			deps = nil;
		};

		deps = deps.collect { |key|
			key = key.asSymbol;
			if (loaded[key].isNil or: { reloaded.includes(key).not }) {
				loaded[key] = "%.scd".format(key).loadRelative[0];
				reloaded.add(key);
			};
			loaded[key].value;
		}

		^fun.value(*deps);
	}

	init {
		reloaded = Set();
		loaded = IdentityDictionary();
	}

}


+ Function {
	require { |deps, reset=false|
		^Req.load(deps, this, reset);
	}
}