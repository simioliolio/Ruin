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
        bufferLengthInit = length;
        bufferLength = playbackLength = bufferLengthInit;
    }
    
    void allocate() {
        buffer = new float [bufferLengthInit];
        bufferLength = playbackLength = bufferLengthInit;
    }
    
    void deallocate() {
        delete [] buffer;
        bufferLength = playbackLength = 0;
    }
    
    float nextAtPlayhead(float speed = 1.0) {
        if (bufferLength == 0) { // no buffer allocated
            return 0.0;
        }
        if (playbackPosition >= playbackLength) {
            playbackPosition = 0;
            playbackWrapCount++;
        }
        float next = valueOfSampleAtPosition(playbackPosition);
        playbackPosition += speed;
        return next;
    }
    
    void nextAtRecordHead(float value) {
        if (bufferLength == 0) { // no buffer allocated
            return;
        }
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
    
    int bufferLengthInit;
    int bufferLength; // absolute length of buffer
    float *buffer;
    int recordPosition = 0;
    float playbackPosition = 0;
    
    float valueOfSampleAtPosition(float inPosition) {
        int positionX0 = floor(inPosition);
        int positionX1 = ceil(inPosition);
        if (positionX0 == positionX1) {
            return buffer[positionX0];
        }
        if (positionX1 >= playbackLength) {
            positionX1 = 0; // wrap
        }
        float Y0 = buffer[positionX0];
        float Y1 = buffer[positionX1];
        float gapBetweenX0AndInPosition = inPosition - positionX0;
        float amplitudeOffset = gapBetweenX0AndInPosition * (Y1 - Y0);
        return Y0 + amplitudeOffset;
    }
};

#endif /* CircularBuffer_hpp */
