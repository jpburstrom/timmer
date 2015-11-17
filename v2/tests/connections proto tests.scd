c = q.f.getProto(\connections);
({1.rrand(10)} ! 5).do(c.add(\foo, _));
c.connectionsFor(\foo)
c.allConnections
c.allConnections.size == 1; //true
d = q.f.getProto(\connections);
({1.rrand(10)} ! 5).do(d.add(\foo, _));
c.replaceWith(d)
c.allConnections

(
//test replaceWith
{
    var c = q.f.getProto(\connections),
    d = c.clone,
    c_vals = ({1.rrand(10)} ! 5).do(c.add(\foo, _)),
    d_vals = ({1.rrand(10)} ! 5).do(d.add(\foo, _)),
    diff = (
        remove: c.allConnections - d.allConnections,
        add: d.allConnections - c.allConnections
    ),
    //Updater removes and adds from diff
    x = Updater(c, { |obj, action, x, y |
        diff[action].remove([x, y]);
        "% %->%".format(action, x, y).postln;
    });
    diff.postln;
    //This replaces all items in c with all items in d, adding and removing
    c.replaceWith(d);
    //Make sure diff is empty now
    (diff[\remove].isEmpty && diff[\add].isEmpty).postln;
    x.free;
    ""
}.value
)
