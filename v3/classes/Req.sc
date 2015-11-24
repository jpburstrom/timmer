//A require for SC
//
Req {
	classvar instance;
	classvar <>alwaysReload;
	var <loaded, <reloaded, <cleanup, <initFuncs, <updateFuncs;
	var <>depToLoad, circularCheck;

	*new {
		^super.new.init;
	}

	*get {
		^( instance ?? { instance = this.new })  // If it doesn't exist yet, create it.
	}

	*load { |deps, initFunc, updateFunc, key, reload=false|
		^this.get.load(deps, initFunc, updateFunc, key, reload);
	}

	load { |deps, initFunc, updateFunc, key, reload=false|
		var result;
		var ck = this.prMakeKey(thisProcess.nowExecutingPath, key);

		//If we're loading dependencies, and this load statement doesn't match the
		//key, just exit
		if (depToLoad.notNil and: { depToLoad != ck }) {
			^false
		};

		{
			//add to circular check to make sure we're not entering a feedback loop
			circularCheck.add(ck);

			if (cleanup[ck].notNil) {
				cleanup[ck].value;
			};

			cleanup[ck] = FunctionList();

			initFuncs[ck] = initFunc;
			updateFuncs[ck] = updateFunc;

			//resolve deps
			//foo/asd => /path/to/foo/asd.scd
			//foo/asd#thing => /path/to/foo/asd.scd#thing
			deps = deps.collect { |dep|
				var keyArray = dep.asString.split($#);
				var path = "%.scd".format(keyArray[0]).resolveRelative;
				var tmpOut;
				dep = this.prMakeKey(path, keyArray[1]);
				//We set current dependency to load
				depToLoad = dep;

				//we load the path, assuming it contains a Req.load statement
				if (reloaded.includes(dep).not  or: reload) {
					if (circularCheck.includes(dep)) {
						"Req: circular dependency. Not loading Req at %".format(dep).warn;
					} {
						tmpOut = path.load;
						//A Req.load statement in the include file would have populated the loaded[dep] slot
						//If not, we put the output of the file instead
						if (loaded[dep].isNil) {
							loaded[dep] = tmpOut;
						}

					};
				};
				tmpOut = loaded[dep].value;
				if (updateFuncs[dep].isFunction) {
					tmpOut = updateFuncs[dep].value(tmpOut);
				};
				tmpOut
			};

			reloaded.add(ck);
			circularCheck.remove(ck);

		}.try({ |error|
			//reset recursion tests on error
			circularCheck.clear;
			depToLoad = nil;

			error.throw;
		});

		//If we're at the end of the recursion, unset depToLoad for next time
		if (circularCheck.isEmpty) {
			depToLoad = nil;
		};

		loaded[ck] = result = initFunc.valueArray(deps ++ cleanup[ck]);

		//If we have an updateFunc, filter the result through that
		if (updateFunc.isFunction) {
			result = updateFunc.value(result);
		};

		^result
	}

	prMakeKey { |path, hash|
		if (hash.notNil) {
			path = File.realpath(path) ++ "#" ++ hash;
		}
		^path.asSymbol;
	}

	init {
		reloaded = Set();
		circularCheck = Set();
		loaded = IdentityDictionary();
        cleanup = IdentityDictionary();
		initFuncs = IdentityDictionary();
		updateFuncs = IdentityDictionary();
	}

}


+ Function {
	require { |deps, reset=false|
		^Req.load(deps, this, reset);
	}
}