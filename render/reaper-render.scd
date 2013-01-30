//Reaper scripted rendering proof of concept
//Make sure to allow sending actions as OSC messages in REAPER

Proto( {
     ~rAddr = NetAddr("localhost", 57121);//Set this port in REAPER OSC options

     ~send =  { |action|
			~rAddr.sendMsg("/action", ~actions[action])
	 };
    ~actions =  (
		 play: 1007,
		 render: 41824,
		 save: 40026,
		 quit: 40004
	 );
	~prepareReaperRender = {
        OSCdef.freeAll;
        OSCdef(\renderOnStart, e { arg msg;
        //only send this once, thank you very much.

            ~start.if {
                ~send.(\render);
                ~send.(\play);
                ~start = false;
            }
        }, '/tempo');

        OSCdef(\quitOnPlay, e { arg msg;
            (msg[1] == 1).if {
                //Need to save before quitting, for some reason REAPER marks the project as dirty
                "QUIT".postln;
                msg.postln;
                ~send.(\save);
                ~send.(\quit);
            }
        }, '/play');

    };

	~doReaperRender = { |projectPath|
		//Open project, set the ~start variable
        var app = "/Applications/REAPER.app/Contents/MacOS/REAPER",
        project = "/tmp/testet/testet.RPP";
        ~start = true;
        (app + project).unixCmd;

	};

    ~freeAll = {
        OSCdef.freeAll
    }
});

