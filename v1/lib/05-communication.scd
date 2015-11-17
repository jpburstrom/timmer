// OSC etc

q.make ({

    //Make OSCdef
    var funcs = (
        onsets: { arg msg;
            msg.postln;
        },
    );

    funcs.keysValuesDo { arg k, v;
        OSCdef(k, v, '/tr', s.addr, nil, [ { arg id; id == q.ctl[k].nodeID }]);
    };



})


