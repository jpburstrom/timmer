//noteView

Proto({
    ~selColors = [\fAmber, \amber, \green, \red];
    ~colors = [\off, \lAmber, \lGreen, \lRed];
    ~out = nil;
    ~updater = nil;
    ~controller = nil;

    ~connect  = { |ctrl, view|
        ~controller = ctrl;
        ~out = view;

        ctrl.addDependant(currentEnvironment);
        currentEnvironment;
    };

    ~update = { |model, state, k, v, sel|
        if (state == \state) {
            var c = ~colors;
            //if selected, choose selected colors
            if (model.isSelected(k)) { c = ~selColors };
            ~out.setColor(~controller.indexAt(k), c[v])
        } {
            if (state == \selected) {
                if (sel) {
                    ~out.setColor(~controller.indexAt(k), ~selColors[v])
                } {
                    ~out.setColor(~controller.indexAt(k), ~colors[v])
                }
            }
        }
    }.inEnvir;

    ~free = {
        ~controller.removeDependant(currentEnvironment);
    }

});
