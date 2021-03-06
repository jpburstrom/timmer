// Interpreter preprocessor, allowing an "/*EOF*/" string in a document
// to stop loading (useful for keeping test code etc, while still being able to load it as external file)
this.preProcessor = { arg str;
    var split = str.findRegexp("/\\*EOF\\*/\\s*$");
    if (split.size > 0) {
        str = str.keep(split[0][0])
    };
    str
};

if (\Document.asClass.notNil) {
    \Document.asClass.globalKeyDownAction = { |doc, char, mod, unicode, key|
        switch(key,
            122, { q.player.playStop }, //F1
            120, { q.player.playPause }, //F2
            99, { q.player.randSeed = 1e+06.rand; q.player.play }, //F3
            118, nil, //F4
            109, Fdef(\showMonitorUI),//F10
            103, {q.playerui.connect(q.player)}, //F11
            111, {q.player.bounce((sampleRate: s.sampleRate))} //F12
        );
    };
};

TempoClock.default.tempo = 1;

q ?? { q = () };
q.do(_.free);
q.clear;
"[0-9]*.scd".resolveRelative.pathMatch.do(_.load);
q.player = "protos/score-player".import;
if (\GUI.asClass.notNil) {
	q.playerui = "protos/score-player-gui".import;
    "gui/*".import;
};

q.stereo = true;

//Use this with a callback function to get a copy of the q object
//So we can run multiple files simultaneously
{ |func| func.value(q.deepCopy) };