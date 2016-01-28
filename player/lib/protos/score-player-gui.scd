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
        ~sfView.setSelectionColor(1, Color.green);
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
        }.inEnvir)
    };

    ~setPosition = { |sec|
        ~sfView.timeCursorPosition = sec * ~sampleRate;
    };

    ~setSelection = { |in, out|
        ~sfView.setSelection(1, [in, out] * ~sampleRate);
    };

    ~update = { |obj, what ... args|
        if (what == \segment) {
            { ~setSelection.(*args) }.inEnvir.defer;
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

