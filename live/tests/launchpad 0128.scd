q ?? { q = () };
(
q.launchIndexes =  (24..63).clump(8).flop.flatten;

q.launchView = Proto({
    ~colors = [\off, \yellow, \green, \red];
    ~out = nil;
    ~updater = nil;
    ~controller = nil;

    ~connect  = { |ctrl|
        ~controller = ctrl;
        ~out = LaunchpadOut(ctrl.ktl);
        ~updater = Updater(~controller, e { |model, state, k, v|
            ~out.setColor(q.launchIndexes[k], ~colors[v])
        });
    }

});
q.launchController = Proto({

    ~model = (connections:"connections proto 0128.scd".loadRelative[0]);
    ~states = [\off, \play, \car, \mod];
    ~ktl = nil;

    ~rout = Routine({ arg kv;
        var key, value, first, cur = List();

        #key, value = kv;
        first = key;

        loop {

            while ({ value == 0 }) {
                #key, value = false.yield;
            };

            first = key;
            cur.add(key);

            while ( {cur.size > 0}) {

                #key, value = [key, value].yield;

                if (key == first and: { value == 0 }) {

                    if (cur.size > 1) {
                        ~setState.(first, 3);
                        cur[1..].do { |x|
                            if (~model[x] != 3) {
                                ~setState.(x, 2, true, first);
                            } {
                                ~setState.(x, 3, true, first);
                            }

                            //TODO: remove connections
                        };

                    } {
                        ~toggleState.(first);
                    };
                    cur.clear;
                } {

                    if (value == 0) {
                        cur.remove(key);
                    } {
                        cur.add(key);
                    }
                }
            };

        }


    });

    ~connect = { |ktl|
        ~ktl = ktl;
        64.do { |x| m.elementAt(\bt, x).action_(~update.inEnvir) };
    };
    ~setState = { |k, v, update=true, other|
        var con = ~model.connections;
        switch (v)
        {0} {
            [k, v].postln;
            con.connectionsTo(k).do { |kee|
                //TODO multiple connections (fan out)?
                if (con.connectionsFrom(kee).size == 1) {
                    ~setState.value(kee, 0, update);
                }
            };
            con.connectionsFrom(k).do { |kee|
                //TODO multiple connections (fan out)?
                if (~model[kee] == 3 and: { con.connectionsTo(kee).size > 0 }) {
                    ~setState.value(kee, 3, update);
                } {
                    if (con.connectionsTo(kee).size == 0) {
                        ~setState.value(kee, 1, update);
                    }
                }
            };
            con.removeAll(k);
        }
        {1} {
            //~model.connections.removeAll(k);
        }
        {2} {
            other !? { con.add(other, k) };
        }
        {3} {
            other !? {
                if (~model[k] == 3) {
                    //Avoid 0->1 & 1->2 & 0->2
                    if (con.connectionsFrom(other).isNil or: { (con.connectionsFrom(k) & con.connectionsFrom(other)).size == 0 } ) {

                    ~model.connections.add(other, k);
                    } {
                        "This connection is too complex for me".postln;
                    }
                } {
                    ~model.connections.add(k, other) ;
                };

            };
        };
        if (update) {
            currentEnvironment.changed(\state, k, v, other);
        };
        ~model[k] = v;

    };

    ~toggleState = { |k, update=true|
        ~setState.(k, ((~model[k] ? 0) == 0).asInt, update);
    };


    ~toggleAll = { |val|
        val ?? { val = 1 - ~model.values.select(_.isNumber).mean.round.min(1) };
        if (val.isNaN) { val = 0 };
        q.launchIndexes.size.do { |x| x.postln; ~setState.value(x, val) };

    };

    ~update = { |e|
        q.launchIndexes.indexOf(e.index) !? {
            ~rout.value([q.launchIndexes.indexOf(e.index), e.value])
        }
    }
});
q.launchController.connect(m);
q.launchView.connect(q.launchController);

);
c = q.launchController.model.connections.con;
