//BCR2000
q.make {


    var mapControlToCV = { |ctl, cv, ctlfunc, cvfunc|
        var acc = q.f.makeAccelerator;
        var sc, v;
        //Default functions
        ctlfunc ?? {
            ctlfunc = { |el|
                cv.input = cv.input + acc.(el.rawValue);
            }
        };
        cvfunc ?? {
            cvfunc = { |cv|
                ctl.value = cv.input;
            }
        };

        //Controller sets CV
        ctl.action_(ctlfunc);

        sc = SimpleController(cv).put(\synch, cvfunc);

        ~simpleContainer.add(sc);

    };

    ~dev.bcr = MKtl('bcr20000');

    value {
        var knobModes, knobs, cvs, buttons, mfuncs;
        var pitches = q.f.getPitchesForUI;

        knobModes = #[delay, amp, mod, macros];

        //Ordered lists of CVs
        cvs = (
            delay: pitches.collect { |x| q.storage[\cvs, \delay, x.asSymbol] },
            amp: pitches.collect { |x| q.storage[\cvs, \amp, x.asSymbol] },
            mod: q.settings.paramLists.mod.collect({ |tup| q.storage.at(\cvs, \modulation, *tup) }),
            macros: q.storage[\cvs, \macros]
        );

        knobs = q.dev.bcr.elementAt(\kn).flat;

        //Go through all cvs
        //each key is a mode, value a list of cvs

        ~mfuncs = List();
        mfuncs = ~mfuncs;

        knobs.do { |el, i|
            var mfunc = MFunc();

            cvs.keysValuesDo { |key, list|
                var cv = list[i];
                var acc = q.f.makeAccelerator;
                mfunc.add(key, { |el|
                        cv.input = cv.input + acc.(el.rawValue);
                });
                mapControlToCV.(el, list[i], mfunc, { |cv|
                    if (mfunc.mode == key) {
                        el.value = cv.input;
                    }
                });
            };

            mfunc.makeExclusiveModes(\modes, knobModes);

            el.action_(mfunc);

            mfuncs.add(mfunc);
        };

        buttons = ~dev.bcr.elementAt(\pr).flat;


        //Knobmode is set by four buttons on the BCR
        knobModes.do { |mode, i|
            var other = buttons.reject { |item, index| index == i };
            buttons[i].action_({ |ev|
                q.f.setBCRKnobMode(mode, i, ev, other);
            });
        };

        q.f.setBCRKnobMode = { |mode, i, ev, other|
            i ?? { i = knobModes.indexOf(mode) };
            ev ?? { ev = buttons[i] };
            other ?? { other = buttons.reject({ |x, y| y == i}) };

            mfuncs.do(_.mode_(mode));
            ev.value = 1;
            other.do(_.value_(0));

            cvs[mode].do(_.changed(\synch));
        };


        q.f.setBCRKnobMode(\delay);



    };





    //defined in init
    q.settings.paramLists.global.do { |key, i|

        var lpRout, lp = false, p = #[delay, amp];

        mapControlToCV.value(
            ~dev.bcr.elementAt(\knUp, 0, i),
            q.storage[\cvs, \global, key]
        );

        ~dev.bcr.elementAt(\tr, 0, i).action_({ |el|
            var cv = q.storage[\cvs, \global, key];

            if (el.value == 1) {
                if (p.includes(key)) {
                    lpRout = fork {
                        0.5.wait;
                        q.storage[\cvs, key].do { |lcv|
                            lcv.value = lcv.spec.default;
                        };
                        cv.value = cv.spec.default;
                        lp = true;
                    }
                }
            } {
                lpRout.stop;
                if (lp.not) {
                    cv.value = cv.spec.default;
                };
                lp = false;
            }

        });

        q.storage[\cvs, \global, key].changed(\synch);


    };


}
