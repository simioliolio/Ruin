//
//  RuinStutterKernel.hpp
//  Ruin
//
//  Created by Simon Haycock on 08/06/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

#ifndef RuinStutterKernel_h
#define RuinStutterKernel_h

#import "RuinAUUtilites/RuinAUUtilites.h"

// TODO: Declare superclass as public?
class RuinStutterKernel : public DSPKernel {
    
public:
    
    RuinStutterKernel() {}
    
    void init(int channelCount) {
        _channelCount = channelCount;
    }
    
    // TODO: move to superclass?
    void setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            
            for (int channel = 0; channel < _channelCount; ++channel) {
                outBufferListPtr->mBuffers[channel].mData = inBufferListPtr->mBuffers[channel].mData;
            }
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
#warning Unimplemented!
    }
    
    void handleMIDIEvent(AUMIDIEvent const& midiEvent) {
#warning Unimplemented!
    }
    
    
private:
    int _channelCount;
    AudioBufferList* inBufferListPtr = nullptr;
    AudioBufferList* outBufferListPtr = nullptr;
};

#endif /* RuinStutterKernel_h */
