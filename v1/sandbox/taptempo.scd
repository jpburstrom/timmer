//practical sound analysis - fredrik olofsson
//organized by lullcec 28-30oct 2011, hangar, barcelona

//--session #03


//--fft


//--beat tracking

//autocorrelation beat tracking - click and hold mouse down to lock beat

(
SynthDef(\beat, {|buffer|
	var src, chain, buf;
	var trackb, trackh, trackq, tempo;
	buf= LocalBuf(1024);		//don't change if 44100
	//src= PlayBuf.ar(2, buffer, BufRateScale.ir(buffer), loop: 1);
	src= SoundIn.ar;
	chain= FFT(buf, Mix(src));
	#trackb, trackh, trackq, tempo= BeatTrack.kr(chain, MouseButton.kr).poll;
	Out.ar(0, DelayN.ar(src, 0.08, 0.08)+SinOsc.ar(400, 0, Decay.kr(trackb, 0.1)));
}).add;
)

d= Buffer.read(s, "/Volumes/Mega/projects/timmer/render/to SC/hits-new.wav")
a= Synth(\beat, [\buffer, d])
a.free
d.free

//test filtering the src[0]
//test delaying the output src 0.05 sec

//see BeatTrack and BeatTrack2 helpfile

key <12 major
key >=12 minor
2	dmaj
12+2= 14 dmin

0-23
14-12

//--key tracking

b= Buffer.alloc(s, 4096, 1);	//don't change if 44100
(
SynthDef(\key, {|buffer|
	var src, chain;
	var key, root, chord;
    // src= PlayBuf.ar(2, buffer, BufRateScale.ir(buffer), loop: 1);
	src= SoundIn.ar;
	chain= FFT(b, Mix(src));
	key= KeyTrack.kr(chain, 2, 0.5).poll;
	key= Median.kr(11, key);
	chord= if(key<12, #[0, 4, 7], #[0, 3, 7]);
	root= if(key<12, key, key-12)+60;
	Out.ar(0, src+Splay.ar(SinOsc.ar((root+chord).midicps, 0, 0.1)));
}).add;
)


d= Buffer.read(s, "sounds/pop3.aiff")
a= Synth(\key, [\buffer, d])
a.free
d.free
b.free

//just a simple test playing a chord for comparison
a= {Splay.ar(LFSaw.ar(([0, 3, 7, 10]+2+60).midicps, 0, 0.1))}.play
a.free



//--exercise - chord tracking


//build a selfplaying arpeggiator

//see PracticalSoundAnalysis03examples.html



//--advanced topics, other low / high-level descriptors

//introduce chromagram
http://web.media.mit.edu/~tristan/phd/dissertation/chapter3.html

//--the phase vocoder

//--tracking harmonic partials

//--low-level feature extraction vs high-level descriptors



//--exercise - feedback

//use one of the previous exercises and let it analyze its own output (with a variable delay)
//or work on free choice / own project
