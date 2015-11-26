//ButtonView
//Showing button state on
Proto({
    ~controller = nil;
    ~lpOut = nil;
    ~colors = [\off, \lRed, \red];
    ~blinkRout = ();
	~elementGroup = nil;

    ~connect = { |ctl, view|
        ~controller = ctl;
		~lpOut = view;

		~elementGroup = ~controller.elementGroup;
        ctl.addDependant(currentEnvironment);
        currentEnvironment;

    };

    ~update = { |obj, what, k, v|
        if (what == \state) {
            var c = ~colors[v].asArray;
            var ctl = ~controller.indexAt(k);
			~blinkRout[k].stop;
			~lpOut.setGroupColor(~elementGroup, ctl, c[0]);
            if (c[1].notNil) {
				//Short blinking
                ~blinkRout[k] = fork {
                    0.1.wait;
                    ~lpOut.setColor(ctl, c[1]);
                }
            }
        }
    }.inEnvir;

    ~free = {
        ~controller.removeDependant(currentEnvironment);
    }.inEnvir;
});
