(1..48)

m = MKtl('launchpad', "*launchpad-mini", true);
m.gui;

//TargetController: 4 states, exclusive in pairs
~keys = (1..47);
p = "../lib/protos/targetController".import.connect(m, ~keys);
~keys.size.do(p.setState(_,0))
p.setState(7, 3) //filled+active, set
p.setState(6, 3) //filled+active, previous is reset to 1
p.setState(7, 2) //empty+active, previous is reset to 1
p.setState(6, 3) //empty+active, previous is reset to 0
p.onLongPress(6)

//test longpress functionality-------
p.setState(6, 3) //empty+active, previous is reset to 0
p.onLongPress(6) == 2
p.setState(6, 2) //empty+active, previous is reset to 0
p.onLongPress(6) == 3
p.setState(6, 0) //empty+active, previous is reset to 0
p.onLongPress(6) == 1
p.setState(6, 1) //empty+active, previous is reset to 0
p.onLongPress(6) == 0

p = "../lib/protos/freezeController".import.connect(m, (48..55));
p.setState(5, 1) //active
p.setState(6, 1) //active, previous is reset to 0
p.setState(6, 0) //inactive
p.setState(5, 1) //active, no reset
