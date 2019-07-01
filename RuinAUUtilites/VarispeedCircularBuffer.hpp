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

class VarispeedCircularBuffer {
    
public:
    
    VarispeedCircularBuffer(int length) {
        bufferLength = length;
        playbackLength = length;
        buffer = new float [length];
    }
    
    ~VarispeedCircularBuffer() {
        delete [] buffer;
    }
    
    float nextAtPlayhead(float speed = 1.0) {
        if (playbackPosition >= playbackLength) {
            playbackPosition = 0;
            playbackWrapCount++;
        }
        float next = buffer[int(playbackPosition)];
        playbackPosition++;
        return next;
    }
    
    void nextAtRecordHead(float value) {
        if (recordPosition >= bufferLength) {
            return; // records once until reset
        }
        buffer[recordPosition] = value;
        recordPosition++;
    }
    
    void reset() {
        playbackLength = bufferLength;
        playbackPosition = 0;
        recordPosition = 0;
        playbackWrapCount = 0;
    }
    
    
public:
    
    int playbackLength; // length of buffer used in playback
    int playbackWrapCount = 0;
    
private:
    
    int bufferLength; // absolute length of buffer
    float *buffer;
    int recordPosition = 0;
    float playbackPosition = 0;
};

#endif /* CircularBuffer_hpp */
