//buttonController
//base proto for snapshots & macros

//Button connects currently selected keys to a slot in the mod matrix
//onButtonPress: |y|
//~ctrls.notes.selected().do { |x| ~matrix.mod.add(x, y) }
x = q.f.getProto(\buttonController).clone({

    var model = q.storage[\matrix, \modulation];
    var togglePtn = [2,2,0];

    ~setStateFunc = \toggleState;
    ~allNotes = false;
    ~isKeyInited = true;



    ~onLongPress = {
        ~allNotes = true;
    };

    ~onStateChange = { |k, v|

        var method = \doSelected;

        if (~allNotes) {
            method = \doAll;
            ~allNotes = false;
        };
        //state 1 is for display only
        if (v != 1) {
            var ar = [\remove, nil, \add][v];
            q.ctrls.notes.perform(method, { |from|
                q.storage[\matrix, \modulation].perform(ar, from, k);
            });
        }

    };

    ~toggleState = { |k|
        //if all notes are in the selection
        //If selection is empty, all are selected
        ~setState.(k, togglePtn[(~model[k] ? 0)]);
    };

    ~unselectAll = {
        ~model.keysValuesDo { |k, v|
            if (v > 0) {
                ~setState.(k, 0);
            }
        }
    };

    q.ctrls.notes.addDependant(currentEnvironment);

    ~update = e { |obj, what, k, v, isSelected|
        if (what == \selected) {
            var sel = q.ctrls.notes.selected;

            //Choose which modulation keys should be fully active
            //and which should be half active
            ~model.keys.do { |dest|
                var con = model.connectionsTo(dest);
                var state = 0;
                if (con.notEmpty) {
                    if ((sel.notEmpty and: { sel.isSubsetOf(con) }) or:
                        { sel.isEmpty and:
                            { con.size == q.ctrls.notes.indexes.size } }) {
                        state = 2;
                    } {
                        if ((con & sel).notEmpty or: { sel.isEmpty }) {
                            state = 1;
                        }
                    }
                } {
                };
                if (~model[dest] != state) { ~setState.(dest, state) };

            };

        }
    };



});

