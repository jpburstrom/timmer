q.make {
    ~f = Proto({
        //include file with proto, located in protos/ directory
        ~getProto = { |file|
            (q.path.lib +/+ "protos/%.scd").format(file).load;
        };

        ~getLatency = {
            q.settings.latencies.sum;
        };

        //Accelerator for relative midi knobs
        //Receives 65/63 (bcr rel mode 2)
        //amount: 1 is standard, higher = more acceleration
        //Outputs a value from 0 -> 1
        ~makeAccelerator = { |amount=1|
            var prevTime = 0;
            var time;
            var delta;
            amount = amount * 0.00007874; //0.01/127

            { |val|
                time = thisThread.seconds;
                delta = time - prevTime;
                prevTime = time;
                //map t
                delta = (amount / delta).max(0.00001).min(0.0315);
                (val - 64) * delta;
            }
        };

        // Sorted pitches for UI knobs
        // 3 6 9 12 ...
        // 2 5 8 11 ...
        // 1 4 7 10 ...
        ~getPitchesForUI = {
            q.settings.pitches.clump(3).collect(_.reverse).flop.flatten
        }

    });

};

defer {

    Toolbar.replace('Save', {
        [\storage].do { |name|
            q[name].writeArchive(q.path.data +/+ "backup/" ++ name + Date.getDate.asSortableString ++ ".archive");
            q[name].writeArchive(q.path.data +/+ name ++ ".archive");
        };
        "Session saved".inform;
    });
    Toolbar.replace('Preamps', { c.gui[\win] !? { c.gui[\win].close; }; c.show });

}
