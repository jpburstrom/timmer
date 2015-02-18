//ButtonView
//Showing button state on
Proto({
    ~controller = nil;
    ~lpOut = nil;
    ~colors = [\off, \lRed, \red];

    ~connect = { |ctl, view|
        ~controller = ctl;
        ~lpOut = view;

        ctl.addDependant(currentEnvironment);
        currentEnvironment;

    };

    ~update = { |obj, what, k, v|
        if (what == \state) {
            ~lpOut.setColor(~controller.indexAt(k), ~colors[v]);
        }
    }.inEnvir;

    ~free = {
        ~controller.removeDependant(currentEnvironment);
    }.inEnvir;
});
