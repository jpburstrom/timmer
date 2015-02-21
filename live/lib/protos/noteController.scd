//noteController
Proto({

    ~model = (selected: Set(), connections: q.f.getProto(\connections));
    ~states = [\off, \play, \car, \mod];
    ~ktl = nil;
    ~indexes = nil;

    ~rout = Routine({ arg kv;
        var key, value, first, longPressRout, longPress=false, cur = List();

        #key, value = kv;
        first = key;

        loop {

            //Handle trailing note-offs
            while ({ value == 0 }) {
                #key, value = false.yield;
            };



            //Here comes the first key press
            first = key;
            cur.add(key);

            longPressRout.stop.free;
            //Wait for long press
            longPressRout = fork {
                0.5.wait;
                cur.do(~select.value(_));
                longPress = true;
            };

            while ( {cur.size > 0}) {

                #key, value = [key, value].yield;

                //FIXME: yield first after longPress
                //while is dangerous?
                while ({longPress}) {
                    if (value == 1) {
                        //TODO toggle select?
                        ~select.(key);

                    } {
                        if (key == first) {
                            longPress = false;
                            cur.clear;
                            first = false;
                        }
                    }

                };
                if (key == first and: { value == 0 }) {
                    //If multiple keys, make connections
                    longPressRout.stop;

                    if (cur.size > 1) {
                        if (~isSelected.(first)) {
                            cur.do(~unselect.(_));
                        } {
                            var con = ~model.connections.connectionsTo(first, true);
                            if (con.notNil and: { (con & cur[1..]).size > 0 }) {
                                "Circular connection -- aborting".warn;
                            } {
                                ~setState.(first, 3);
                                cur[1..].do { |x|
                                    if (~model[x] != 3) {
                                        ~setState.(x, 2, true, first);
                                    } {
                                        ~setState.(x, 3, true, first);
                                    }

                                };
                            }
                        }

                    } {
                        //If current (only) key is selected, unselect
                        if (~isSelected.(key)) {
                            ~unselect.(key);
                        } {
                            //... otherwise toggle state
                            ~toggleState.(first);
                        }
                    };
                    cur.clear;
                } {
                    //If key is not first, add or remove to current collection

                    if (value == 0) {
                        cur.remove(key);
                    } {
                        cur.add(key);
                    }
                }
            };

        }


    });

    //Connect model to launchpad
    ~connect = { |ktl, keys|
        ~ktl = ktl;
        keys.do { |x| ktl.elementAt(\bt, x).action_(~update.inEnvir) };
        ~indexes = keys;
        currentEnvironment
    };

    //Main state-setting method
    ~setState = { |k, v, update=true, other|
        var con = ~model.connections;
        switch (v)
        {0} {
            //Recursively remove connections
            con.connectionsTo(k).copy.do { |kee|
                if (con.connectionsFrom(kee).size == 1) {
                    ~setState.value(kee, 0, update);
                }
            };
            //Check connections from k, aka carriers
            con.connectionsFrom(k).do { |kee|
                //TODO multiple connections (fan out)?
                //If modula
                if (~model[kee] == 3 and: { con.connectionsTo(kee).size > 0 }) {
                    //FIXME: Why setState?
                    ~setState.value(kee, 3, update);
                } {
                    //make carrier normal if it has no other connections
                    if ((con.connectionsTo(kee) - [k]).size == 0) {
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

    //Select a key (for modal ui)
    ~select = { |k|
        ~model.selected.add(k);
        currentEnvironment.changed(\selected, k, ~model[k] ? 0, true);
    };

    //Unselect key
    ~unselect = { |k|
        ~model.selected.remove(k);
        currentEnvironment.changed(\selected, k, ~model[k] ? 0, false);
    };

    ~toggleState = { |k, update=true|
        ~setState.(k, ((~model[k] ? 0) == 0).asInt, update);

    };

    ~isSelected = { |k|
        ~model.selected.includes(k);
    };

    ~selected = {
        ~model.selected.copy;
    };

    ~doSelected = { |func, allFunc|
        var result;
        allFunc ??  { allFunc = func };
        if (~model.selected.isEmpty.not) {
            result = ~model.selected.asArray.do(func);
        } {
            result = ~indexes.size.do(allFunc);
        };
    };

    ~doAll = { |func|
        ~indexes.size.do(func);
    };


    ~toggleAll = { |val|
        val ?? { val = 1 - ~model.values.select(_.isNumber).mean.round.min(1) };
        if (val.isNaN) { val = 0 };
        q.launchIndexes.size.do { |x| ~setState.value(x, val) };

    };

    ~update = { |e|
        ~indexes.indexOf(e.index) !? {
            ~rout.value([~indexes.indexOf(e.index), e.value])
        }

    };

    ~indexAt = { |i|
        ~indexes.at(i);
    };

    //Freeing LaunchPad Mktl on behalf of all
    ~free = {
        ~ktl.allElements.do(_.reset);
        ~ktl.free;
    }

});