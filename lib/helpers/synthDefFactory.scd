/*
This file is evaluated within the q environment
(q.path.lib +/+ "helpers/synthDefFactory.scd").load;
q.makeDef(\synth)
*/
var fact = {


    var factory = { arg name, func, lags, options;
        var optionParent = (
            channels: 2,
            pan: true,
            panLag: 0,
            panDefault: 0,
            amp: true,
            ampLag: 0,
            ampDefault: 1,
            width: true,
            widthLag: 0,
            widthDefault: 1,
            preSend: 0,
            preSendLag: 0,
            preSendDefault:0,
            postSend: 0,
            postSendLag: 0,
            postSendDefault:0,
            variants: [],
            inBus: \bus,
            inRate: \ar,
            inClass: In,
            outBus: \bus,
            outRate: \ar,
            outClass: Out,
        );
        options = (options ?? ()).parent_(optionParent);
        SynthDef(name, {
            var snd, env;
            if (options.inBus.isSymbol) {
                snd = options.inClass.perform(options.inRate,
                    options.inBus.kr, options.numChannels);
                snd = SynthDef.wrap(func, lags, [snd]);
            } {
                snd = SynthDef.wrap(func, lags);
            };
            options.preSend.do { |i|
                var bus = ("preSendBus" ++ (i + 1)).asSymbol,
                amp = ("preSendAmp" ++ (i + 1)).asSymbol;
                options.outClass.asClass.perform(options.outRate,
                    bus.kr, snd * amp.kr(options.preSendDefault, options.preSendLag, true));
            };
            if (options.channels == 2 and: { options.width }) {
                snd = Splay.ar(snd, \width.kr(options.widthDefault, options.widthLag, true));
            };
            if (options.pan) {
                if (options.channels == 1) {
                    snd = Pan2.ar(snd, \pan.kr(options.panDefault, options.panLag, true))
                } {
                    snd = Balance2.ar(snd[0], snd[1], \pan.kr(options.panDefault, options.panLag, true))
                }
            };
            if (options.amp) {
                snd = snd * \amp.kr(options.ampDefault, options.ampLag, true);
            };
            options.postSend.do { |i|
                var bus = ("postSendBus" ++ (i + 1)).asSymbol,
                amp = ("postSendAmp" ++ (i + 1)).asSymbol;
                options.outClass.perform(options.outRate,
                    bus.kr, snd * amp.kr(options.postSendDefault, options.postSendLag, true));
            };
            if (options.outBus.isSymbol) {
                if (options.outClass.name == \XOut) {
                    env = EnvGen.kr(Env.asr(\fadeTime.kr(1, 0, true), 1, \fadeTime.kr(1, 0, true), curve:\cub), \gate.kr(1,0, true), doneAction:2);
                    XOut.perform(options.outRate, options.outBus.kr, \wet.kr(1, 0.1, true) * env, snd);
                } {
                    options.outClass.perform(options.outRate, options.outBus.kr, snd)
                }

            }
            },
            variants: options.variants).add;
    };

    ~synth = { arg name, func, lags, options;
        var optionParent = (
            inBus: false,
            outClass: OffsetOut,
        );
        options = (options ?? ()).proto_(optionParent);
        factory.(name, func, lags, options);
    };

    ~synthIn = { arg name, func, lags, options;
        var optionParent = (
            outClass: OffsetOut,
        );
        options = (options ?? ()).proto_(optionParent);
        factory.(name, func, lags, options);
    };

    //Sending k-rate controls
    ~ctl = { arg name, func, lags, options;
        var optionParent = (
            inRate: \kr,
            outRate: \kr,
            pan: false,
            amp: false,
            width: false,
            outClass: ReplaceOut
        );
        options = (options ?? ()).proto_(optionParent);
        factory.(name, func, lags, options);
    };

    //Receiving audio, sending k-rate controls
    ~ctla2k = { arg name, func, lags, options;
        var optionParent = (
            outRate: \kr,
            pan: false,
            amp: false,
            width: false,
        );
        options = (options ?? ()).proto_(optionParent);
        factory.(name, func, lags, options);
    };

    //Insert effect
    ~fx = { arg name, func, lags, options;

        var optionParent = (
            outClass: XOut
        );

        options = (options ?? ()).proto_(optionParent);
        factory.(name, func, lags, options);
    };

    //Send effect
    ~send = { arg name, func, lags, options;
        var optionParent = ();
        options = (options ?? ()).proto_(optionParent);
        factory.(name, func, lags, options);
    };

};

~makeDef = { arg type, name, func, lags, options;
    Environment.make(fact).at(type).value(name, func, lags, options)
};


~makeDefs = { arg ... args;
    var type = args.removeAt(0);
    args.do { arg x; ~makeDef.(type, *x) };
}
