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
#import <iostream>
#import <algorithm>

enum {
    StutterParameterEnable = 0,
    StutterParameterLength = 1
};

class RuinStutterKernel : public DSPKernel {
    
public:
    
    RuinStutterKernel() {}
    
    void init(int inChannelCount) {
        channelCount = inChannelCount;
        enableRamper.init();
        lengthRamper.init();
    }
    
    void reset() {
        enableRamper.reset();
        lengthRamper.reset();
    }
    
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case StutterParameterEnable:
                enableRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;
            case StutterParameterLength:
                lengthRamper.setUIValue(clamp(value / 1000.0f, 0.001f, 2.0f));
                break;
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case StutterParameterEnable:
                return enableRamper.getUIValue();
                break;
            case StutterParameterLength:
                return lengthRamper.getUIValue() * 1000.0f;
                break;
            default:
                std::cout << "Setting unknown parameter" << std::endl;
                abort();
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
        switch (address) {
            case StutterParameterEnable:
                enableRamper.startRamp(value, duration);
                break;
            case StutterParameterLength:
                lengthRamper.startRamp(clamp(value / 1000.0f, 0.001f, 2.0f), duration);
                break;
        }
    }
    
    // TODO: move to superclass?
    void setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            
            for (int channel = 0; channel < channelCount; ++channel) {
                outBufferListPtr->mBuffers[channel].mData = inBufferListPtr->mBuffers[channel].mData;
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
    ParameterRamper enableRamper = 0; // off or on
    ParameterRamper lengthRamper = 1; // length in s
};

#endif /* RuinStutterKernel_h */
