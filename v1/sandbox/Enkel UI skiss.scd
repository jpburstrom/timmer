var w = Window.new.front.fullScreen;
var w2 = UserView(w, Window.screenBounds.insetBy(10,10));
var r = w2.bounds;
var totalWidth = r.width;

w.background_(Color.blue);

w2.drawFunc = {
    Pen.color = Color.white;
    Pen.moveTo(0,0);
    Pen.addRect(r);
    Pen.fill;
};


{
    var f = 0;
    inf.do { |i|
        f = ((f * 0.998) + ((-0.5).rrand(1) * 0.002));
        r.width = totalWidth * f;
        w2.refresh;
        0.02.wait
    };
}.fork(AppClock)



