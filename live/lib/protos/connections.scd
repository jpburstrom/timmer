x = Proto({
    ~con = ();

    //Add connection
    //Return false if connection already exists
    ~add = { |from, to|
        ~con[from] = ~con[from] ?? { (to:Set(), from:Set()) };
        ~con[to] = ~con[to] ?? { (to:Set(), from:Set()) };
        if (~con[from].to.includes(to).not) {
            ~con[from].to.add(to);
            ~con[to].from.add(from);
            currentEnvironment.changed(\add, from, to);
        } {
            false;
        };
    };

    ~remove = { |from, to|
        if (~con[from].to.includes(to)) {
            ~con[from].to.remove(to);
            ~con[to].from.remove(from);
            currentEnvironment.changed(\remove, from, to);
        } {
            false;
        };
    };

    ~removeFrom = { |from|
        ~con[from] !? {
            ~con[from].to.do { |to|
                ~con[to].from.remove(from);
            };
            ~con[from].to.clear;
        }
    };

    ~removeTo = { |to|
        ~con[to] !? {
            ~con[to].from.do { |from|
                 ~con[from].to.remove(to) ;
            };
            ~con[to].from.clear;
        }
    };

    ~removeAll = { |fromto|
        ~removeFrom.(fromto);
        ~removeTo.(fromto);

    };


    ~exists = { |from, to|
        ~con[from].notNil and: {~con[from].to.includes(to) and: { ~con[to].from.includes(from) } };
    };

    ~connectionsFor =  { |x|
        ~con[x];
    };

    ~connectionsFrom = { |x, r=false|
        ~con[x] !? {
            if (r.not) {
                ~con[x].to;
            } {
                var v = Set();
                ~con[x].to.do({ |y| v = v.add(y) | ~connectionsFrom.(y, r) });
                v;
            }
        };
    };

    ~connectionsTo = { |x, r=false|
                ~con[x] !? {
            if (r.not) {
                ~con[x].from;
            } {
                var v = Set();
                ~con[x].from.do({ |y| v = v.add(y) | ~connectionsTo.(y, r) });
                v;
            }
        };
    };

    //Return a Set of associations representing all connections
    //(from->to)
    ~allConnections = {
        ~con.collect( { |v, k|
            v.from.collect { |i| [i, k] }
    }).asArray.reduce('|') ??  { Set() };
    };

    ~reset = {
        ~con = ();
    };


    //------------Snapshot support -------------//

    //Replace current connections with connections from other proto (eg snapshots)
    ~replaceWith = { |other|
        var these = ~allConnections.value;
        var those = other.allConnections;
        (these - those).do { |x|
            ~remove.(x[0], x[1]);
        };
        (those - these).do { |x|
            ~add.(x.[0], x[1]);
        };
    };

    //snapshots uses setValue
    ~setValue = { |other|
        ~replaceWith.(other);
    };

    //for snapshots, Proto.value uses ~next
    //So we can do x.setValue(y.value)
    //which corresponds to x.replaceWith(y)
    ~next = {
        currentEnvironment
    };

    //---------End snapshot support-----------------//

});
