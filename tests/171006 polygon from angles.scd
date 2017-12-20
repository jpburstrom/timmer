(
~durs = [120, 140, 230, 500, 90, 720, 380];

~angles = ~durs.normalizeSum * 360;
~radius = 250;
)

//~angles = 90 ! 4;

~durs.sum;

120 b

(
var u = UserView(nil, Rect(0, 0, 500, 500));
//center point: middle of window
var center = 250@250;

u.background = Color.white;
u.drawFunc_({|v|

    80.do {
        var an = 0;
        var first = false;

        //A list of song durations
        ~durs = {1.0.rand}!7;
        // ~durs = [120, 140, 230, 500, 90, 720, 380].scramble;
        //Convert these to angles, sum equals 360 degrees

        ~angles = [0] ++ ~durs.normalizeSum * 360;
        //Set radius here
        ~radius = 250;

        Pen.strokeColor = Color.gray(1.0.rand);

        Pen.rotate(360.rand, 250, 250);
        //Move to the first point
        Pen.moveTo((center + Point(0, ~radius)).postln);

        //For each angle
        ~hepp = ~angles.collect { |angle|
            var x, y;
            //Add angle
            an = an + angle;

            //Some trigonometry I don't remember
            x = center.x + (sin(an * (pi / 180)) * ~radius);
            y = center.y + (cos(an * (pi / 180)) * ~radius);

            //Draw line from current to this position
            Pen.lineTo(x@y);

            // angle

            x@y
        };

        //Stroke it!
        Pen.stroke;
    }

});
u.mouseDownAction_({|v|
    v.refresh;
});
u.front;
)

~toLength = { |a, b|
    ((a.x - b.x).pow(2) + (a.y - b.y).pow(2)).sqrt;
};



//Test, doesn't work
x = List();
x.array.normalizeSum
~durs.normalizeSum
~hepp.doAdjacentPairs({|a, b| x.add(~toLength.(a, b)); });