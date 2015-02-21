Proto({
    ~con = ();

    //Add connection
    //Return false if connection already exists
    ~add = { |from, to|
        ~con[from] = ~con[from] ?? { (to:Set(), from:Set()) };
        ~con[to] = ~con[to] ?? { (to:Set(), from:Set()) };
        if (~con[from].to.includes(to).not) {
            ~con[from].to.add(to);
            ~con[to].from.add(from);
        } {
            false;
        };
    };

    ~remove = { |from, to|
        if (~con[from].to.includes(to)) {
            ~con[from].to.remove(to);
            ~con[to].from.remove(from);
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

    ~connectionsFrom = { |x|
        ~con[x] !? { ~con[x].from };
    };

    ~connectionsTo = { |x|
        ~con[x] !? { ~con[x].to };
    };

    ~reset = {
        ~con = ();
    }

});