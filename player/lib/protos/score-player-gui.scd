Proto({

    ~controller = nil;

    ~makeWindow = {

        ~sfView = SoundFileView();
        ~buttonContainer = HLayout();
        ~window = Window("TIMMER", Rect(0, Window.availableBounds.height, Window.availableBounds.width, 500)).layout_(VLayout(~buttonContainer, ~sfView));
        ~sfView.background = Color.white;
        ~sfView.gridOn = false;
        ~sfView.timeCursorOn = true;
        ~sfView.timeCursorColor = Color.black;
        ~sfView.setEditableSelectionStart(0, false);
        ~sfView.setEditableSelectionSize(0, false);
        ~sfView.currentSelection_(0);
        ~sfView.setSelectionColor(0, Color.white);
        ~sfView.setSelectionColor(63, Color.green);
        ~window.front;

        ~sfView.mouseUpAction_({ |obj, x, y, mod, btn|
            if (btn == 0) {
                currentEnvironment.changed(\position, obj.timeCursorPosition / ~sampleRate)
            }
        }.inEnvir);

        ~sfView.keyDownAction_({ |obj, char|
            switch (char,
                //Space
                $ , {
                    ~controller.playPause;
                },
                $-, {
                    ~sfView.zoom(1.5);
                },
                $+, {
                    ~sfView.zoom(0.75);
                },
                $s, {
                    ~sfView.zoomSelection(0);
                },
                $a, {
                    ~sfView.zoomAllOut;
                    ~resetSelection.value;
                },
                $f, {
                    ~follow = true;
                }



            );
        }.inEnvir);
    };

    ~connect = { |ctrl|
        ~removeController.value;
        ctrl.addDependant(currentEnvironment);
        currentEnvironment.addDependant(ctrl);
        ~controller = ctrl;
        ~openFile.value(ctrl.songPath);
    };

    ~openFile =  { |path|
        if (~sfView.isNil) {
            ~makeWindow.value;
        };
        SoundFile.use(path, { |sf|
            ~sfView.readFileWithTask(sf, showProgress:true);
            ~sampleRate = sf.sampleRate;
            if (~controller.data[~controller.tickLabel].size <= 62) {
                var colors = [Color.white, Color.fromHexString("eeeeee")];
                ~controller.data[~controller.tickLabel].do { |pair, i|
                    ~sfView.setSelection(i + 1, (pair * ~sampleRate).round);
                    ~sfView.setSelectionColor(i + 1, colors[i%2]);
                };
            }
        }.inEnvir)
    };
    ~setPosition = { |sec|
        ~sfView.timeCursorPosition = sec * ~sampleRate;
    };

    ~setSelection = { |in, out|
        ~currentSelection = [in, out];
        ~sfView.setSelection(63, [in, out] * ~sampleRate);
        ~sfView.setSelection(0, [in - 0.2, out + 0.4] * ~sampleRate);
    };

    ~resetSelection = {
        ~setSelection.value(*~currentSelection);
    };

    ~update = { |obj, what ... args|
        if (what == \segment) {
            {
                ~setSelection.(*args);
                if (~follow.notNil) {
                    ~sfView.zoomSelection(0);
                };
                ~log
            }.inEnvir.defer;
        } {
            if (what == \load) {
                ~openFile.value(args[0]);
            }
        }
    };

    ~free = {
        ~window !? { ~window.close };
        ~sfView = nil;

    };

    ~removeController = {
        if (~controller.notNil) {
            ~controller.removeDependant(currentEnvironment);
            currentEnvironment.removeDependant(~controller);
        }
    }
});

