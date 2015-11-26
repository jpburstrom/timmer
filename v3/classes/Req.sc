//A require for SC
//
Req {
	classvar instance;
	classvar <>alwaysReload;
	var <loaded, <reloaded, <cleanup, <initFuncs, <updateFuncs, <depMap;
	var <>depToLoad, <circularCheck, forceReload=false;

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

		if (reload && forceReload.not) {
			reloaded.clear;
			forceReload = true;
		};
		//add to circular check to make sure we're not entering a feedback loop
		circularCheck.add(ck);

		if (cleanup[ck].notNil) {
			cleanup[ck].value;
		};

		cleanup[ck] = FunctionList();

		initFuncs[ck] = initFunc;
		updateFuncs[ck] = updateFunc;

		depMap.removeFrom(ck);


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

			depMap.add(ck, dep);

			//Add dep t
			//loaded[ck][1].add(dep);

			//we load the path, assuming it contains a Req.load statement
			if (loaded[dep].isNil or: { reloaded.includes(dep).not  and: forceReload }) {
				this.prLoadDep(dep);
			};
			tmpOut = loaded[dep];
			if (updateFuncs[dep].isFunction) {
				tmpOut = updateFuncs[dep].value(tmpOut);
			};
			tmpOut
		};

		reloaded.add(ck);

		try {
			loaded[ck] = result = initFunc.valueArray(deps ++ cleanup[ck]);
		} { |error|

			//reset recursion tests on error
			circularCheck = IdentityBag();
			depToLoad = nil;
			forceReload = false;
			error.throw;
		};


		//If we have an updateFunc, filter the result through that
		if (updateFunc.isFunction) {
			result = updateFunc.value(result);
		};

		//We need to update those who depend on us as well
		// "loading those who depend on %".format(ck).debug;
		//depMap.to(ck).do(this.prLoadDep(_));

		//If we're at the end of the recursion, unset for next time
		if (circularCheck.size == 1 and: { circularCheck.includes(ck) } ) {
			depToLoad = nil;
			forceReload = false;
			// "done".debug;

		};

		circularCheck.remove(ck);


		^result
	}

	prMakeKey { |path, hash|
		if (hash.notNil) {
			path = File.realpath(path) ++ "#" ++ hash;
		}
		^path.asSymbol;
	}

	prLoadDep { |dep|
		var tmpOut, path;
		depToLoad = dep;


		path = dep.asString.split($#)[0];

		// path.debug("trying to load");
		// circularCheck.debug("circularcheck");

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
		// loaded[dep].debug("loaded dep %".format(dep));
	}


	init {
		forceReload = false;
		depToLoad = nil;
		reloaded = Set();
		circularCheck = IdentityBag();
		depMap = Connections();
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