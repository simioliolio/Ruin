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
        buffer = new float [length];
    }
    
    ~VarispeedCircularBuffer() {
        delete [] buffer;
    }
    
    float nextAtPlayhead(float speed = 1.0) {
        if (playbackPosition >= bufferLength) {
            playbackPosition -= bufferLength;
        }
        float next = buffer[int(playbackPosition)];
        playbackPosition++;
        return next;
    }
    
    void nextAtRecordHead(float value) {
        if (recordPosition >= bufferLength) {
            recordPosition -= bufferLength;
        }
        buffer[recordPosition] = value;
        recordPosition++;
    }
    
private:
    
    int bufferLength;
    float *buffer;
    int recordPosition = 0;
    float playbackPosition = 0;
};

#endif /* CircularBuffer_hpp */
