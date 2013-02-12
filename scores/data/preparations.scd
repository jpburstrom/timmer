//--------------------------------------------------

//Fetch midi data for snickarglädje

q.use( {
    var m, e, durations, amp, events;
    m = SimpleMIDIFile.read(~path.data +/+ "5.2-Snickarglädje.mid");
    m.timeMode = \seconds;
    durations = (m.noteOnEvents.flop[1]).differentiate.add(20);
    amp = [Rest()] ++ (m.noteOnEvents.flop[5] / 127);
    e = [dur: Pseq(durations), amp: Pseq(amp)];
    e.writeArchive(~path.data +/+ "5.2-Snickarglädje.archive");
})        