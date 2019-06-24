//
//  CircularBuffer.hpp
//  RuinAUUtilites
//
//  Created by Simon Haycock on 23/06/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

#ifndef CircularBuffer_hpp
#define CircularBuffer_hpp

#include <stdio.h>

class CircularBuffer {
    
public:
    
    CircularBuffer(int length) {
        bufferLength = length;
        buffer = new float [length];
    }
    
    ~CircularBuffer() {
        delete [] buffer;
    }
    
    float nextAtPlayhead() {
        if (playbackPosition > bufferLength) {
            playbackPosition = 0;
        }
        float next = buffer[playbackPosition];
        playbackPosition++;
        return next;
    }
    
    void nextAtRecordHead(float value) {
        if (recordPosition > bufferLength) {
            recordPosition = 0;
        }
        buffer[recordPosition] = value;
        recordPosition++;
    }
    
private:
    
    int bufferLength;
    float *buffer;
    int recordPosition = 0;
    int playbackPosition = 0;
};

#endif /* CircularBuffer_hpp */
