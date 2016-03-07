Tdef(\bosse, { |ev|
    var c = 0;

    loop {
        c = c + 1;
        if (0.1.coin) {
            c = (c - 4).max(0);
        };
        c.postln;
        ev.hello.postln;
        0.3.wait;
    }
}).play


//Score format:
//First item is absolute time, and the atom of the piece. Could be every onset or something
//Second item is the duration of the atom
//Optional pairs: region name and duration
//abs_time dur region dur region dur
2.3 0.2 asd 2.2 foo 5.5

//or maybe region duration is optional
2.3 0.2 tag1 tag2 region 2.2 foo 5.5


//or even
#[2.3, 0.2, [tag1], [tag2], [region 2.2], [foo 5.5]]

//or maybe, more consistent
2.3 tag1 tag2 0.2 tag3 tag4 0.6 tag7 2.4



//Extract tags from all:
(
var scoreEvent = [2.3, \onset, \blue, 0.2, \phrase, 2.2];
var things = ();
var tags = List();
scoreEvent[1..].do { |x|
    if (x.isNumber) {
        tags.do { |t|
            t.postln;
            x.postln;
            things[t] = things[t].add([scoreEvent[0], x]);
        };
        tags.clear;

    } {
        tags.add(x)
    }
};
things.postcs
)

//Now we have this:
(
a = ( 'onset': [ [ 2.3, 0.2 ], [2.5, 0.4] ], 'phrase': [ [ 2.3, 2.2 ] ], 'blue': [ [ 2.3, 0.2 ] ] );
b = ();
c = (
    //This function is called every onset
   onset: { |ev|
        "onset".postln;
        ev.next;
        //TODO: (optionally) set wait time and next segment
    },
    phrase: { |ev|

    }
);
a.keysValuesDo { |k,v|
    b[k] = TaskProxy({ |ev|
        if (c[k].notNil) {
            a[k][0][0].wait;
            while ({ a[k][ev.index].notNil }) {
                var func = c[k];
                ev.waitTime = a[k][ev.index][1];
                ev.index = ev.index + 1;
                func.value(ev);
                ev.waitTime.wait;
            }
        }
        //This event would have helper functions, like
        //wait
        //reverse
        //next (needs alias)
        //To control the stream
    }).envir_((index:0, score:a));
}
)

b.do(_.play(quant:0))

//BUT this doesn't work. a single task is probably better, to handle jumps at multiple levels. We have the atom, which could be onsets or something else, and phrases and other things made up from those

//score format: abs_time dur [label] [id] [label] [id]

2.3 0.2 onset 0
2.5 0.3 onset 1
2.8 0.2 onset 2
...

//Multiple labels:

...
2.3 0.2 onset 0 phrase 0 part 2
2.5 0.3 onset 1 phrase 0 part 2
2.8 0.2 onset 2 phrase 1 part 3
...

//So we could build a score from a set of labelled markers:
|onset,phrase   |onset    |onset,phrase
//or multiple markers with common locations
//maybe phrase markers location could be rounded to closest onset location

//so we cook it into something like this
[2.3, 0.2, (onset:0, phrase:2)]

//or maybe this
//where some labels (time, dur) are reserved
(time:2.3, dur:0.2, onset:0, phrase:2)

//And we would also need a way to look up start and end points
(phrase:[[0.2,2.3],[2.3,4.6]])




