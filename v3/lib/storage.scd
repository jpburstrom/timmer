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

		~storePreset = { |k|
			k.debug("storing preset");
			params.getPresetParams.do { arg x, i;
				~presets[k][i] = x.value;
			};
			~save.value;
		};

		~storeSnapshot = { |k|
			k.debug("storing snapshot");
			params.getSnapshotParams.do { arg x, i;
				~snapshots[k][i] = x.value;
			}
		};

        ~removePreset = { |k|
            k.debug("removing preset");
            ~toStore[\presets].remove(k);
            params.getParams(\presets)[k] = params.randomize(\presets);
        };

        ~removeSnapshot = { |k|
            k.debug("removing snapshot");
            ~toStore[\snapshots].remove(k);
            params.getParams(\snapshots)[k] = params.randomize(\snapshots);
        };

        ~getPresets = {
            ~things[\presets];
        };

        ~getSnapshots = {
            ~things[\snapshots];
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
    q.storage = storage;
	storage;
});