~mangle = Proto({
    //Convert beats
    ~beat = { |path|
        var bpm, t, f;
        t = TabFileReader.read(path);
        //Loop through lines, empty bpm value == previous
        if (t[0][1].split($ )[1] == "bpm") {
            var dur;
            f = File(path, "w");
            t.doAdjacentPairs { |line, next|
                //Convert to bps if it hasn't been done yet
                dur = next[0].asFloat - line[0].asFloat;
                line[1] !? { bpm = line[1].split($ )[0] };
                bpm = bpm.asFloat / 60;
                f.write("%\t%\t%\n".format(line[0], bpm, dur));
            };
            f.close;
            "File converted successfully".postln;
        } {
            "File already converted".postln;
        }

    }
});

~mangle.beat("02/beat.txt".resolveRelative);


(
var magic_offset = 91.914;
var f, t = FileReader.read("03/onset-old.txt".resolveRelative);
t = t.collect(_[0].asFloat);
t = t.reject(_ < magic_offset);
t = t - magic_offset;
f = File("03/onset.txt".resolveRelative,"w");
t.do { |n|
    f.write("%\n".format(n));
};
f.close;
)