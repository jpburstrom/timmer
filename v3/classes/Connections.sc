Connections {
	var con;

	*new {
		^super.new.reset;
	}

	reset {
		con = IdentityDictionary(know:true);
	}

	//Add connection
    //Return false if connection already exists
	add { |from, to|
        con[from] = con[from] ?? { (to:Set(), from:Set()) };
        con[to] = con[to] ?? { (to:Set(), from:Set()) };
        if (con[from].to.includes(to).not) {
            con[from].to.add(to);
            con[to].from.add(from);
            this.changed(\add, from, to);
        } {
            ^false;
        };
		^this;
    }

    remove { |from, to|
        if (con[from].to.includes(to)) {
            con[from].to.remove(to);
            con[to].from.remove(from);
            this.changed(\remove, from, to);
        } {
            false;
        };
    }

   removeFrom { |from|
        con[from] !? {
            con[from].to.do { |to|
                con[to].from.remove(from);
            };
            con[from].to.clear;
        }
    }

    removeTo { |to|
        con[to] !? {
            con[to].from.do { |from|
                 con[from].to.remove(to) ;
            };
            con[to].from.clear;
        }
    }

    removeFor { |fromto|
        this.removeFrom(fromto);
        this.removeTo(fromto);
    }


    exists { |from, to|
        ^con[from].notNil and: {con[from].to.includes(to) and: { con[to].from.includes(from) } };
    }

    for  { |x|
        ^con[x];
    }

    from { |x, r=false|
        var out = con[x] !? {
            if (r.not) {
                con[x].to;
            } {
                var v = Set();
                con[x].to.do({ |y| v = v.add(y) | this.from(y, r) });
                v;
            }
        };
		^out;
    }

    to { |x, r=false|
        var out = con[x] !? {
            if (r.not) {
                con[x].from;
            } {
                var v = Set();
                con[x].from.do({ |y| v = v.add(y) | this.to(y, r) });
                v;
            }
        };
		^out;
    }

    //Return a Set of associations representing all connections
    //(from->to)
    all {
        var out = con.collect( { |v, k|
            v.from.collect { |i| [i, k] }
		}).asArray.reduce('|') ??  { Set() };
		^out;
    }


    //------------Snapshot support -------------//

    //Replace current connections with connections from other proto (eg snapshots)
    replaceWith { |other|
        var these = this.all;
		var those = other.all;
        (these - those).do { |x|
            this.remove(x[0], x[1]);
        };
        (those - these).do { |x|
            this.add(x.[0], x[1]);
        };
    }

    //snapshots uses setValue
    setValue { |other|
        this.replaceWith(other);
    }

    //for snapshots, Proto.value uses next
    //So we can do x.setValue(y.value)
    //which corresponds to x.replaceWith(y)
    next {
        ^this
    }

    //---------End snapshot support-----------------//

}
