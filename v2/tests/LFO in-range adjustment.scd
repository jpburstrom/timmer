//LFO in-range adjustment
(
{
    //Original value
    var val = 0.2;
    //LFO depth -- ramping from min to max
    var lfoVal = Line.kr(0, 1);
    //The LFO, in range (-0.5, 0.5)
    var lfo = SinOsc.ar(50, 0, 0.5) * lfoVal;
    //Original value's distance to edge (min or max)
    var edgeDistance = 0.5 - (0.5 - val).abs;
    //LFO adjust -- start adjustment when (lfoVal * 0.5) == edgeDistance,
    //and end at (0.5 - edgeDistance)
    var lfoAdjust = ((lfoVal * 0.5) - edgeDistance).max(0);
    //Clunky way to check if we want to add or subtract the adjustment
    lfoAdjust = lfoAdjust * (((val - edgeDistance).ceil * 2) - 1);


    (val - lfoAdjust) + lfo;

}.plot(1)
)
