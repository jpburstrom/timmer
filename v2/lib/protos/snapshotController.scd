//snapshotController
q.f.getProto(\buttonController).clone({

    ~onLongPress = { |k|
        q.snapshots.save(k);
    };

    ~onShortPress = { |k|
        q.snapshots.load(k);
    };

    ~onStateChange = { |k, v|
        //Deactivate active
        if (v == 2) {
            ~model.active !? {
                ~setState.(~model.active, 1)
            };
        };
        ~model.active = k;
    }


});
