//ButtonView
//Showing button state on
Proto({
    ~controller = nil;
    ~lpOut = nil;
    ~colors = [\off, \lRed, \red];
    ~blinkRout = ();

    ~connect = { |ctl, view|
        ~controller = ctl;
        ~lpOut = view;

        ctl.addDependant(currentEnvironment);
        currentEnvironment;

    };

    ~update = { |obj, what, k, v|
        if (what == \state) {
            var c = ~colors[v].asArray;
            var ctl = ~controller.indexAt(k);
            ~blinkRout[k].stop;
            ~lpOut.setColor(ctl, c[0]);
            if (c[1].notNil) {
                ~blinkRout[k] = fork {
                    0.3.wait;
                    ~lpOut.setColor(ctl, c[1]);
                }
            }
        }
    }.inEnvir;

    ~free = {
        ~controller.removeDependant(currentEnvironment);
    }.inEnvir;
});
