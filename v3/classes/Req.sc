//A require for SC
//
Req {
	classvar instance;
	classvar <>alwaysReload;
	var <loaded, <reloaded, <cleanup;

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

        var ck = thisProcess.nowExecutingPath.asSymbol;
        if (cleanup[ck].notNil) {
            cleanup[ck].value;
        };

        cleanup[ck] = FunctionList();

		if (reset) {
			this.reloaded.clear;
		};

		if (deps.isFunction) {
			fun = deps;
			deps = nil;
		};

		deps = deps.collect { |key|
            var path = "%.scd".format(key).resolveRelative;
            key = path.asSymbol;
			if (loaded[key].isNil or: { reloaded.includes(key).not }) {
				loaded[key] = path.load;
				reloaded.add(key);
			};
			loaded[key].value;
		}

        ^fun.valueArray(deps ++ cleanup[ck]);
	}



	init {
		reloaded = Set();
		loaded = IdentityDictionary();
        cleanup = IdentityDictionary();
	}

}


+ Function {
	require { |deps, reset=false|
		^Req.load(deps, this, reset);
	}
}