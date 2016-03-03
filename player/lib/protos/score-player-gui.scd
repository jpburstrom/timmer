Proto({

    ~controller = nil;

    ~follow = false;

    ~makeWindow = {

        ~sfView = SoundFileView();
        ~buttonContainer = HLayout();
        ~clockLabel = StaticText().string_("00:00").stringColor_(Color.white);
        ~buttonContainer.add(~clockLabel);
        ~window = Window("TIMMER", Rect(0, Window.availableBounds.height, Window.availableBounds.width - 450, 500)).layout_(VLayout(~buttonContainer, ~sfView));
		~statusBox = StatusBox(~window);
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
        ~window.onClose = {
            ~removeController.();
            ~window = nil;
        }.inEnvir;
        ~window.front;

        ~envirGuiIgnoreKeys = #[bufnum, dummy, hasGate, id, msgFunc, server];

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
                },

                $d, {
                    ~openEnvirGui.value;
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
        if (~window.isNil) {
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
                    ~envirGui !? {
                        ~controller.currentEvent.keysValuesDo { |k,v|
                            if (~envirGuiIgnoreKeys.includes(k).not) {
                                ~envirGui.envir[k] = v;
                            }
                        }
                    }
                }.inEnvir.defer;
            },
            \load,  {
                ~openFile.value(args[0]);
            },
            \state, {
                ~setClock.(*args);
                //Stop/start clock
            }
        );
    };

    ~clockRoutine = Task({
        var seconds = ~clockStartPos ?? 0;
        var string;
        //Set clock to seconds.floor and wait the remainder
        var initWait = (1 - (seconds % 1));
        var setString = {
            ~clockLabel.string_(
                "%:%".format(seconds.div(60).asStringToBase(10, 2),
                    (seconds % 60).asStringToBase(10, 2));
            );
        };
        seconds = seconds.floor.asInt;
        setString.value;
        initWait.wait;
        loop {
            seconds = seconds + 1;
            setString.value;
            1.wait;
        }
    }.inEnvir, AppClock);

    ~setClock = { |state, secs|
        switch(state,
            \playing, {
                ~clockStartPos = secs;
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

    ~openEnvirGui = {
        var ev = ();
        ~controller.currentEvent !? { |x|
            x.keysValuesDo { |k,v|
                if (~envirGuiIgnoreKeys.includes(k).not) {
                    ev[k] = v;
                }
            };
        };
        ~envirGui = EnvirGui(ev, 30, nil, Rect(Window.availableBounds.width-450, Window.availableBounds.height, 450, 300));
        ~controller.actionLabels.do { |x|
            ~envirGui.putSpec(x, [0, ~controller.data[x].size, \lin, 1] )
        };
    };

    ~free = {
        ~clockRoutine.stop;
        ~envirGui !? { ~envirGui.close } ;
        ~window !? {
            ~window.onClose = nil;
            ~window.close;
        };
        ~sfView = nil;

    };

    ~removeController = {
        if (~controller.notNil) {
            ~controller.removeDependant(currentEnvironment);
            currentEnvironment.removeDependant(~controller);
        }
    };

	~log = { |msg, pre|
		var val = msg;
		var tick = ~controller.currentEvent !? (_[~controller.tickLabel]) ? 0;
		if (pre.notNil) {
			msg = "%: %".format(pre, msg);
		};
		{
			~statusBox.postln("%\t%\t%".format(~clockLabel.string, tick, msg));
		}.inEnvir.defer;

		//Return value for chaining
		val
	}
});

