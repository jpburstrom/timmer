Fdef(\showMonitorUI, {
    ().use {
        var skipper;
        var labels = [\fx, \main];
        var spec = \ampx4.asSpec;
        var valText = ();
        var action = { |target|
            { |ui|
                q !? {
                    if (q.player.readyForPlay) {
                        q.player.t.monitor[target].vol = spec.map(ui.value);
                    }
                }
            }
        };
        ~win = Window.new.front.layout_(GridLayout.rows(
            labels.collect({ |lbl| currentEnvironment[lbl] = Slider(); currentEnvironment[lbl] }),
            labels.collect { |lbl| StaticText().align_(\center).string_(lbl.asString.toUpper) },
            labels.collect { |lbl| valText[lbl] = NumberBox().align_(\center); valText[lbl] }
        ));
        labels.do { |lbl|
            var sl = currentEnvironment[lbl];
            sl.action = action.(lbl);

        };
        skipper = SkipJack({
            q !? {
                if (q.player.readyForPlay) {

                    var mon = q.player.t.monitor;
                    labels.do { |lbl|
                        currentEnvironment[lbl].enabled_(true).value_(spec.unmap(mon[lbl].vol));
                        valText[lbl].value_(mon[lbl].vol);
                    }
                } {
                    labels.do { |lbl|
                        currentEnvironment[lbl].enabled_(false);
                    }
                }
            }
        });
        ~win.view.keyDownAction_ { |view, char, mod, unic|
            if (unic == 27) {
                view.close;
            }
        };
        ~win.onClose = { skipper.stop };
    }
});