Req.load(['params'], { |params, cleanup|
	//TODO: load from disk
	//Kolla på hur gamla grejer har gjort detta
	var storage = Proto({

        var storageVersion = "0.1.1"; //Avoid float rounding errors
		var path = "../data/storage.zarchive".resolveRelative;

		//Sets of indexes to store
		~toStore = (
            presets: Set(),
            snapshots: Set()
        );

		//Store preset k in group grp
		~storeToGroup = { |grp, k|
			"Storing % in grp %".format(k, grp).postln;
			~things[grp][k] = params.getParams(grp).collect(_.value);
			~toStore[grp].add(k);
			currentEnvironment.changed(\activeKeys, grp);
			~save.value;
		};

		~storePreset = (~storeToGroup.(\presets, _));
		~storeSnapshot = (~storeToGroup.(\snapshots, _));

		//Remove a stored preset
        ~removeFromGroup = { |grp, k|
			~toStore[grp].remove(k);
			~things[grp][k] = params.randomize(grp);
		    currentEnvironment.changed(\activeKeys, grp);
    		~save.value;
        };

		~loadToGroup = { |grp, k|
			params.setParams(grp, ~things[grp][k]);
		};

		~removeSnapshot = (~removeFromGroup.(\snapshots,_));
		~removePreset = (~removeFromGroup.(\presets,_));

		~getPresets = {
            ~things[\presets];
        };

        ~getSnapshots = {
            ~things[\snapshots];
        };

		~getActiveKeys = { |k|
			~toStore[k];
		};

		//Save current state in group
		~saveSingle = { |group, path|
			var x, saver;
			saver = {
				x = params.getParams(group).collect(_.value);
				~prWrite.(x, path);
			}.inEnvir;
			if (path.isNil) {
				Dialog.savePanel({ |p|
					path = p.splitext;
					if (path[1].isNil) { path[1] = "zarchive" };
					path = "%.%".format(*path);
					saver.value;
				});
			} {
				saver.value;
			}
		};

		//Save current state in group
		~loadSingle = { |group, path, storeToKey|
			var x, loader;
			loader = {
				params.setParams(group, ~prRead.(path));
				if (storeToKey.notNil) {
					~storeToGroup.(group, storeToKey);
				}
			}.inEnvir;
			if (path.isNil) {
				Dialog.openPanel({ |p|
					path = p;
					loader.value
				});
			} {
				loader.value
			}

		};

		~save = { |p|
            var z;
			var x = ~things.deepCopy;
            [\presets, \snapshots].do { |grp|
				~things[grp].keysValuesDo { |k,v|
				    if (~toStore[grp].includes(k).not) {
						x[grp][k] = nil;
                    };
                }
            };
			p ?? { p = path };
           ~prWrite.(x, p);

		};

		~backup = {
			var dir = path.resolveRelative.dirname +/+ "backup";
			var file = path.basename.splitext;
			File.mkdir(dir);
			File.copy(path, dir +/+ file[0] ++ Date.getDate.stamp ++ "." ++ file[1]);
		};

		~load = { |p|
            var z;
			p ?? { p = path };
            if (File.exists(p)) {
				~things = ~prRead.(p);
                if (~things.version != storageVersion) {
                    "creating new storage".inform;
                    ~createStorage.value;
					//TODO: copy old storage into new?
                };
                ~toStore[\presets] = ~things.presets.keys;
                ~toStore[\snapshots] = ~things.snapshots.keys;
            } {
                ~createStorage.value;
            };
            params.presetCount.do { |x|
                ~maybeRandomize.(\presets, x);
            };
            params.snapshotCount.do { |x|
                ~maybeRandomize.(\snapshots, x);
            };
			//A bit of a hack
			//Set eq from preset 0
			//Since we're not doing it anywhere else
			~loadToGroup.(\eq, 0);

		};

		~loadDialog = {
			Dialog.openPanel({ |p|
				~load.value(p);
				//TODO later think about how to load everything more smoothly
				~loadToGroup.(\snapshots, 0);
				~loadToGroup.(\presets, params.meta.target.value.asInt);

			}.inEnvir);
		};

		~saveDialog = {
			Dialog.savePanel(~save.inEnvir);
		};

        ~maybeRandomize = { |container, num|
			var c = ~things[container];
			if (c[num].isNil) {
	            c[num] = params.randomize(container);
            }
        };

        ~createStorage = {
            ~things = (
                version: storageVersion,
				eq: (),
				presets: (),
                snapshots: ()

            );
            ~save.value;
        };

		~prWrite = { |x, p|
			z = ZArchive.write(p);
            z.writeItem(x);
            z.writeClose;
		};

		~prRead = { |p|
			var things;
			z = ZArchive.read(p);
			things = z.readItem;
			z.close;
			things;

		}


	});
	storage.load;
    q.storage = storage; //XXX temp
	storage;
});