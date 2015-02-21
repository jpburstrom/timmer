//Snapshots

//Preparation:
//1. All CVs/Refs should be stored in a dictionary in q.storage.cvs
//2. Add the key of the dictionary: q.snapshots.addSnapshotKey(\myKey)

//Usage:
//3. Save snapshot: q.snapshots.save(\snapshotName)
//4. Recall snapshot: q.snapshot.load(\snapshotName)
(
q.make {

    ~snapshots = Proto({

        ~excludePaths = Set().add([\snapshots]);

        //Add key to exclude from snapshots
        ~addExcludePath = { |key|
            ~excludePaths.add(key);
        };

        ~save = { |key|
            var x = q.storage.deepCopy;
            ~excludePaths.do(x.removeAtPath(_));
            q.storage[\snapshots, key] = x;
            currentEnvironment.changed(\save, key);
        };

        ~load = { |key|
            q.storage[\snapshots, key] !? {
                q.storage[\snapshots, key].leafDo { arg path, val;
                    var item = q.storage.atPath(path);
                    if (item.notNil) {
                        if (item.respondsTo(\setValue)) {
                            item.setValue(val.value).changed(\synch);
                        } {
                            item.value_(val.value).changed(\synch);
                        }
                    } {
                        "Snapshot: Invalid key: %".format(path).warn;
                    }
                }
            };
            currentEnvironment.changed(\load, key);
        };

        ~exists = { |key|
            q.storage[\snapshots, key].notNil
        }

    });
}
);


/*
q.snapshots.addSnapshotKey(\cvs);
q.storage.dontsave = "nonono";
q.storage.cvs.foo.value = 0;
q.snapshots.save(\foo);
q.storage.cvs.foo.value = 1;
q.storage.cvs.foo.value
q.snapshots.load(\foo);
q.storage.cvs.foo.value

q.storage.snapshots.foo.cvs.foo.value

x.goo = 2929292
g = Set().add(\goo)
x.select { |v, k| g.includes(k) }
*/
