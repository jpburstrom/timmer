(
~firestudio.quit;
~firestudio = Server(\firestudio, NetAddr("localhost", 57112));
~firestudio.options.device = "Sammanslagen enhet";
~firestudio.options.sampleRate = 48000;
~firestudio.options.numInputBusChannels = 8;
~firestudio.options.numOutputBusChannels = 8;

~firestudio.reboot;
)


s.boot
s.meter
s.quit
s.options.device = "Sammanslagen enhet"


~firestudio.meter

b = Buffer.alloc(s, 65536, 2);
(
fork {
	b.write(leaveOpen:true);
	s.sync;
	x = { DiskOut.ar(b, SoundIn.ar([0,1])); DC.ar(0) }.play;
}
)
x.stop; b.close;

record

x = Ndef(\test, { SoundIn.ar([0,1]) }).record
x.unpause

x.close

Ndef(\test, { SoundIn.ar([0,1]) }).gui

