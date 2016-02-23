//A frequency shifter which tries to avoid aliasing when using negative shifts
FreqShiftAA {
	*ar { arg in, freq=0, phase=0, mul=1, add=0;

		//Steep high pass filter

		4.do { in = HPF.ar(in, freq.neg.max(5)) };

		^FreqShift.ar(in, freq, phase, mul, add);

	}
}

