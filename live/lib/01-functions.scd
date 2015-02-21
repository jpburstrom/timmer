q.make {
    ~f = Proto({
        //include file with proto, located in protos/ directory
        ~getProto = { |file|
            (q.path.lib +/+ "protos/%.scd").format(file).load;
        };

        ~getLatency = {
            q.settings.latencies.sum;
        }


    });

};

defer {

    Toolbar.replace('Save', {
        [\storage].do { |name|
            q[name].writeArchive(q.path.data +/+ "backup/" ++ name + Date.getDate.asSortableString ++ ".archive");
            q[name].writeArchive(q.path.data +/+ name ++ ".archive");
        }
    });
    Toolbar.replace('Preamps', { c.gui[\win] !? { c.gui[\win].close; }; c.show });

}
