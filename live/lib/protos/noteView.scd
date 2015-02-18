//noteView

Proto({
    ~colors = [\off, \amber, \green, \red];
    ~selColors = [\fYellow, \fAmber, \fGreen, \fRed];
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
            ~out.setColor(q.launchIndexes[k], c[v])
        } {
            if (state == \selected) {
                if (sel) {
                    ~out.setColor(q.launchIndexes[k], ~selColors[v])
                } {
                    ~out.setColor(q.launchIndexes[k], ~colors[v])
                }
            }
        }
    };

    ~free = {
        ~controller.removeDependant(currentEnvironment);
    }

});
