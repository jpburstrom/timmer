Req.load(['params'], { |params, cleanup|
	//TODO: load from disk
	//Kolla på hur gamla grejer har gjort detta
	var storage = Proto({

        var storageVersion = "0.1"; //Avoid float rounding errors
		var path = "../data/storage.zarchive".resolveRelative;

        ~toStore = (
            presets: Set(),
            snapshots: Set()
        );

		~storeToGroup = { |grp, k|
			"Storing % in grp %".format(k, grp).postln;
			params.getParams(grp).do { arg x, i;
				~things[grp][k][i] = x.value;
			};
			~toStore[grp].add(k);
			currentEnvironment.changed(\activeKeys, grp);
			~save.value;
		};

		~storePreset = (~storeToGroup.(\presets, _));
		~storeSnapshot = (~storeToGroup.(\snapshots, _));

        ~removeFromGroup = { |grp, k|
			~toStore[grp].remove(k);
			~things[grp][k] = params.randomize(grp);
			[grp, k].debug("removing preset");
            currentEnvironment.changed(\activeKeys, grp);
    		~save.value;
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

		~save = {
            var z;
			var x = ~things.deepCopy;
            [\presets, \snapshots].do { |grp|
                x[grp].keysValuesChange { |k,v|
                    if (~toStore[grp].includes(k)) {
                        v;
                    } {
                        nil;
                    };
                }
            };
            z = ZArchive.write(path);
            z.writeItem(x);
            z.writeClose;

		};

		~load = {
            var z;
            if (File.exists(path)) {
                z = ZArchive.read(path);
                ~things = z.readItem;
                z.close;
                if (~things.version != storageVersion) {
                    "creating new storage".inform;
                    ~createStorage.value;
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
		};

        ~maybeRandomize = { |container, num|
			var c = ~things[container];
			if (c[num].isNil) {
				[container, num].debug("randomizing");
                c[num] = params.randomize(container);
            }
        };

        ~createStorage = {
            ~things = (
                version: storageVersion,
                presets: (),
                snapshots: ()
            );
            ~save.value;
        }


	});
	storage.load;
    q.storage = storage; //XXX temp
	storage;
});