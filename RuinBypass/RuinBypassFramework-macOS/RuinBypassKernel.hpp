//
//  RuinBypassKernel.hpp
//  RuinBypassFramework-macOS
//
//  Created by Simon Haycock on 28/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

#ifndef RuinBypassKernel_h
#define RuinBypassKernel_h

#import <algorithm>

#import "DSPKernel.hpp"

class RuinBypassKernel : public DSPKernel {
    
public:
    
    RuinBypassKernel() { }
    
    void init(int inChannelCount) {
        channelCount = inChannelCount;
    }
    
    void allocateBuffer() { }
    
    void deallocateBuffer() { }
    
    void reset() { }
    
    void setParameter(AUParameterAddress address, AUValue value) { }
    
    AUValue getParameter(AUParameterAddress address) {
        return 0;
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) { }
    
    void setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            
            int frameOffset = int(frameIndex + bufferOffset);
            
            for (int channel = 0; channel < channelCount; ++channel) {
                
                float* in = (float*)inBufferListPtr->mBuffers[channel].mData + frameOffset;
                float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                *out = *in;
            }
        }
    }
    
    void handleMIDIEvent(AUMIDIEvent const& midiEvent) {
        // Does not handle MIDI
    }
    
private:
    int channelCount;
    AudioBufferList* inBufferListPtr = nullptr;
    AudioBufferList* outBufferListPtr = nullptr;
};


#endif /* RuinBypassKernel_h */
