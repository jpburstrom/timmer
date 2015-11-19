q.dev ?? { q.dev = (); } //XXX TEMP

(
q.make {

    var pageSwitchButtons;

    q.dev.bcr = MKtl(\bcr, "*bcr2000");
    q.dev.bcr.gui;
    q.dev.bcr.elementAt(\kn).reset;

    ~bottomEnc = q.dev.bcr.elementAt(\kn).flat;

    //----Top encoders-----------
    //Don't set any model values here -- bottom 32 should do that
    ~topRow = q.dev.bcr.elementAt(\knUp, \1);
    ~topRow.action = { |elem|
        //Index is either 0 or 1 -- check with second row of button rows
        var rowIndex = q.dev.bcr.elementAt(\bt, \2, elem.index).value.asInt;
        q.dev.bcr.elementAt(\kn, rowIndex, elem.index).value = elem.value;

    }.inEnvir;

    //Top encoder buttons----------
    //Mute/set current to default
    q.dev.bcr.elementAt(\tr, \1).action = { |elem|
        //Todo -- set default value? Mute/Solo?
        if (elem.value == 1) {
            ~topRow.at(elem.index).valueAction = 0;
        }
    }.inEnvir;



    //----Bottom encoders (32)-------
    v = (pr_1_1: 0!32, pr_1_2:0!32); //TODO: get preset values
    m = MFunc();

    //---------first page: misc----------
    m.add(\pr_1_1, { |elem, grp, row|
        var knobRows = [\1,\2];

        //If first two rows, set upper encoder value and set buttons to corresponding row
        if (knobRows.includes(grp.index)) {
            q.topRow.at(elem.index).value = elem.value;
            q.dev.bcr.elementAt(\bt, grp.index, elem.index).valueAction=1;
            q.dev.bcr.elementAt(\bt, 1 - knobRows.indexOf(grp.index), elem.index).valueAction=0;
        };

        //TODO: set model values
        //This is a placeholder
        v[\pr_1_1][~bottomEnc.indexOf(elem)] = elem.value;


    }.inEnvir);

    //--------------second page: eq gain---------
    m.add(\pr_1_2, { |elem, grp, row|

        //TODO: set model values
        //This is a placeholder
        v[\pr_1_2][~bottomEnc.indexOf(elem)] = elem.value;

    }.inEnvir);

    //--------Switch pages with two bottom-right buttons------
    m.makeExclusiveModes(\pageswitch, [\pr_1_1, \pr_1_2]);

    {
        pageSwitchButtons = q.dev.bcr.elementAt(\pr, \1).flat;
        q.dev.bcr.elementAt(\pr, \1).action = { |elem, grp|
            m.mode_(elem.name);
            grp.at(1 - pageSwitchButtons.indexOf(elem)).deviceValue = 0;
            elem.deviceValue = 127;
            q.dev.bcr.elementAt(\kn).disable;
            q.dev.bcr.elementAt(\kn).flat.do({ |x, i|
                x.valueAction = v[elem.name][i];
            });
            q.dev.bcr.elementAt(\kn).enable;
        }
    }.value;

    //Sync with presets etc
    q.dev.bcr.elementAt(\kn).action = m;
    q.dev.bcr.elementAt(\pr, \1, \1).valueAction = 1;
    q.dev.bcr.sync;

};

)
