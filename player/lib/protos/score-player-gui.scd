Proto({

    ~controller = nil;

    ~follow = false;

    ~makeWindow = {

        ~sfView = SoundFileView();
        ~buttonContainer = HLayout();
        ~clockLabel = StaticText().string_("00:00").stringColor_(Color.white);
        ~buttonContainer.add(~clockLabel);
        ~window = Window("TIMMER", Rect(0, Window.availableBounds.height, Window.availableBounds.width, 500)).layout_(VLayout(~buttonContainer, ~sfView));
        ~window.background = Color.black;
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
                    ~follow = ~follow.not;
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

        switch(what,
            \segment,
            {
                {
                    ~setSelection.(*args);
                    if (~follow) {
                        ~sfView.zoomSelection(0);
                    };
                    ~log
                }.inEnvir.defer
            },
            \load,  {
                ~openFile.value(args[0]);
            },
            \state, {
                ~setClock.(args[0]);
                //Stop/start clock
            }
        );
    };

    ~clockRoutine = Task({
        var seconds = 0;
        var string;
        loop {
            string = "%:%".format(seconds.div(60).asStringToBase(10, 2),
                (seconds % 60).asStringToBase(10, 2));
            seconds = seconds + 1;
            ~clockLabel.string_(string);
            1.wait;
        }
    }, AppClock);

    ~setClock = { |state|
        switch(state,
            \playing, {
                ~clockRoutine.play;
            },
            \stopped, {
                ~clockRoutine.stop;
                ~clockRoutine.reset;
                ~clockLabel.string_("00:00");
            },
            \paused, {
                ~clockRoutine.pause;
            }
        );
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

