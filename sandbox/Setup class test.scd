(
q !?  { q.freeAll };
q = Setup({
    ~send = Setup({
        ~main = Bus(\audio, 0);
        ~rfx1 = Bus(\audio, 2);
        ~rfx2 = Bus(\audio, 4);
        ~rfx3 = Bus(\audio, 6);
        ~test = Bus.audio(s, 1);
    }, \boot);

    ~buf = Setup({
    }, \boot);

    ~group = Setup({
        //"Give me a group".postln;
        ~test = Group(s);
        ~test2 = Group(s, \addToTail);
        ~foo = Group(~test2);
    }, \tree);

    ~synth = Setup({ |p|
        p.at(\group).test.postln; //This  works
    });

});
"---Wait for setup---"
)

SimpleController(q).put(\build, { |status|
    s.queryAllNodes;
    status.postln;
    "Init----".postln;

})

SimpleController(q.group).put(\build, {
    s.queryAllNodes
});

SimpleController(q.testing).put(\build, {
    "hello".postln
});


