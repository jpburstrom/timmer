"reqtest2.scd".resolveRelative.asSymbol.load

thisProcess.nowExecutingPath

e = (key: FunctionList())
e[\key].addFunc({"hello".postln})
e.key.value

e.foo = {"hello".postln}

e.key

nil ++ 2

f = { |...args| args.postln }

d = [2,3,4]
e = 5
f.valueArray(d++e)

Req.load([\reqtest2], { |rt2, cleanup|
    rt2.postln;
    cleanup.addFunc( { "hello".postln });
});