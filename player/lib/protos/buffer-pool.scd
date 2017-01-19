//Proto allocates 10 buffers
Proto({

    ~buffers = [];
    ~bufSize = 32768;

    ~initBuffers = { |count, channels(2)|
        ~counter = 0;
        ~buffers = count.collect { Buffer.alloc(s, ~bufSize, channels) };
    };

    //Round-robin buffer selection.
    //Returns buffer
    ~next = { |sf, pos|
        ~counter = ~counter + 1 % ~buffers.size;
        ~buffers[~counter].cueSoundFile(sf.path, pos * sf.sampleRate);
    };

    ~reset = {
        ~buffers.do(_.free);
    }

});


