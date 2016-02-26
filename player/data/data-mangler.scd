~mangle = Proto({
    //Convert beats
    ~beat = { |path|
        var bpm, t, f;
        t = TabFileReader.read(path);
        //Loop through lines, empty bpm value == previous
        if (t[0][1].split($ )[1] == "bpm") {
            f = File(path, "w");
            t.do { |line|
                //Convert to bps if it hasn't been done yet
                line[1] !? { bpm = line[1].split($ )[0] };
                bpm = bpm.asFloat / 60;
                f.write("%\t%\n".format(line[0], bpm));
            };
            f.close;
            "File converted successfully".postln;
        } {
            "File already converted".postln;
        }

    }
});

~mangle.beat("02/beat.txt".resolveRelative);
