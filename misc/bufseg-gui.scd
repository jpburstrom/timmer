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

        ~sfView.mouseUpAction_({ |v| currentEnvironment.changed(\position, v.timeCursorPosition / ~sampleRate) }.inEnvir);
    };

    ~connect = { |ctrl|
        ctrl.addDependant(currentEnvironment);
        currentEnvironment.addDependant(ctrl);
        ~controller = ctrl;

        ~openFile.value(ctrl.songPath);
    };

    ~openFile =  { |path|
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

    ~update = { |obj, what, thing|
        what.postln;
        if (what == \newEvent) {
            thing.postln;
        };
    };

    ~free = {
        ~window.close;
        ~controller.removeDependant(currentEnvironment);
        currentEnvironment.removeDependant(~controller);
    }

});

