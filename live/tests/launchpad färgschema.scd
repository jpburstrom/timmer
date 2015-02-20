m = MKtl('lnch0');
x = LaunchpadOut(m);
x.midiOut.control(0, 0, 40);
//Snapshots
4.do(x.setColor(_, \red)); //Active
x.setColor(3, \lRed); //inactive (unused)
//Mod routing
((8 * (1..4)) +.x (0..7)).do(x.setColor(_, \off));
[9,17,24, 27, 33,37].do(x.setColor(_, \yellow));
((0,8..16) +.x (4..7)).do(x.setColor(_, \lGreen));
x.setColor(6, \green);

((0..7) +.x (8 * (5..7))).do (x.setColor(_, [\green, \amber, \red, \off].wchoose([0.1,0.1,0.1,0.7])))


