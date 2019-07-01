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
#import "BoolStateChangeTracker.hpp"
#import <iostream>
#import <algorithm>

enum {
    StutterParameterEnable = 0,
    StutterParameterLength = 1
};

static const int StutterMaxLengthInMS = 2000;
static const int StutterMinLengthInMS = 1;

class RuinStutterKernel : public DSPKernel {
    
public:
    
    RuinStutterKernel() {}
    
    void init(int inChannelCount, double inSampleRate) {
        channelCount = inChannelCount;
        sampleRate = inSampleRate;
        enableRamper.init();
        lengthRamper.init();
        dezipperRampDuration = (AUAudioFrameCount)floor(0.02 * inSampleRate);
        buffer = VarispeedCircularBuffer(inSampleRate * secondsFromMS(StutterMaxLengthInMS) * inChannelCount);
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
                lengthRamper.setUIValue(clamp(secondsFromMS(value), 0.001f, 2.0f));
                break;
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case StutterParameterEnable:
                return enableRamper.getUIValue();
            case StutterParameterLength:
                return msFromSeconds(lengthRamper.getUIValue());
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
                lengthRamper.startRamp(clamp(secondsFromMS(value), 0.001f, 2.0f), duration);
                break;
        }
    }
    
    // TODO: move to superclass?
    void setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        
        enableRamper.dezipperCheck(0); // instant
        lengthRamper.dezipperCheck(0); //
        
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            
            // not ramping
            bool enableParameter = double(enableRamper.getAndStep()) > 0.0;
            double lengthParameter = double(lengthRamper.getAndStep());
            
            // set mode for current frame
            switch (enableStateTracker.hasStateChanged(enableParameter)) {
                case BoolStateChangeResultUnchanged:
                    // tumbleweed
                    break;
                case BoolStateChangeResultEnabled:
                    // stutter has just been enabled. reset buffers to 0 and set mode to record
                    buffer.reset();
                    stutterState = StutterStateRecord;
                    break;
                case BoolStateChangeResultDisabled:
                    // stutter has just been disabled. set mode back to passthrough
                    stutterState = StutterStatePassthrough;
                    break;
            }
            
            int frameOffset = int(frameIndex + bufferOffset);
            
            for (int channel = 0; channel < channelCount; ++channel) {
                
                float* in = (float*)inBufferListPtr->mBuffers[channel].mData + frameOffset;
                float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                switch (stutterState) {
                    case StutterStatePassthrough:
                        *out = *in;
                        break;
                    case StutterStateRecord:
                        buffer.nextAtRecordHead(*in);
                        [[fallthrough]];
                    case StutterStatePlayback:
                        // TODO: Expensive
                        buffer.playbackLength = int(lengthParameter * sampleRate * channelCount);
                        *out = buffer.nextAtPlayhead();
                        // after one wrap, the buffer no longer needs to record
                        if (buffer.playbackWrapCount > 0) {
                            stutterState = StutterStatePlayback;
                        }
                }
            }
        }
    }
    
    void handleMIDIEvent(AUMIDIEvent const& midiEvent) {
        // Does not handle MIDI
    }
    
    
private:
    int channelCount;
    float sampleRate;
    AudioBufferList* inBufferListPtr = nullptr;
    AudioBufferList* outBufferListPtr = nullptr;
    ParameterRamper enableRamper = {0}; // off or on
    ParameterRamper lengthRamper = {1}; // length in s
    AUAudioFrameCount dezipperRampDuration;
    VarispeedCircularBuffer buffer = VarispeedCircularBuffer(88200);
    BoolStateChangeTracker enableStateTracker = false;
    
    float secondsFromMS(float ms) {
        return ms / 1000.0;
    }
    
    float msFromSeconds(float s) {
        return s * 1000.0;
    }
    
    enum StutterState {
        StutterStatePassthrough = 0,
        StutterStateRecord = 1,
        StutterStatePlayback = 2
    };
    
    StutterState stutterState = StutterStatePassthrough;
};

#endif /* RuinStutterKernel_h */
