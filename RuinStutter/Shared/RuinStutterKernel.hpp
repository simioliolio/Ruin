//
//  RuinStutterKernel.hpp
//  Ruin
//
//  Created by Simon Haycock on 08/06/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

#ifndef RuinStutterKernel_h
#define RuinStutterKernel_h

#import <iostream>
#import <algorithm>
#include <vector>
#import "DSPKernel.hpp"
#import "VarispeedCircularBuffer.hpp"
#import "BoolStateChangeTracker.hpp"
#import "ParameterRamper.hpp"

enum {
    StutterParameterEnable = 0,
    StutterParameterLength = 1,
    StutterParameterPitch = 2
};

static const int StutterMaxLengthInMS = 2000;
static const int StutterMinLengthInMS = 1;
static const float StutterMinPitchAsRatio = 0.5;
static const float StutterMaxPitchAsRatio = 2.0;

class RuinStutterKernel : public DSPKernel {
    
public:
    
    RuinStutterKernel() {}
    
    void init(int inChannelCount, double inSampleRate) {
        channelCount = inChannelCount;
        sampleRate = inSampleRate;
        enableRamper.init();
        lengthRamper.init();
        pitchRamper.init();
        dezipperRampDuration = (AUAudioFrameCount)floor(0.02 * inSampleRate);
        int numberOfSamplesInBuffers = inSampleRate * secondsFromMS(StutterMaxLengthInMS) * inChannelCount;
        for (int i = 0; i < inChannelCount; i++) {
            VarispeedCircularBuffer *buffer = new VarispeedCircularBuffer(numberOfSamplesInBuffers);
            buffers.push_back(buffer);
        }
    }
    
    void allocateBuffer() {
        for(std::size_t i=0; i<buffers.size(); ++i) {
            buffers[i]->allocate();
        }
    }
    
    void deallocateBuffer() {
        for(std::size_t i=0; i<buffers.size(); ++i) {
            buffers[i]->deallocate();
        }
    }
    
    void reset() {
        enableRamper.reset();
        lengthRamper.reset();
        pitchRamper.reset();
    }
    
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case StutterParameterEnable:
                enableRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;
            case StutterParameterLength:
                lengthRamper.setUIValue(clamp(secondsFromMS(value), 0.001f, 2.0f)); // TODO: Use min and max constants
                break;
            case StutterParameterPitch:
                pitchRamper.setUIValue(clamp(value, StutterMinPitchAsRatio, StutterMaxPitchAsRatio));
                break;
            default:
                std::cout << "Setting unknown parameter" << std::endl;
                abort();
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case StutterParameterEnable:
                return enableRamper.getUIValue();
            case StutterParameterLength:
                return msFromSeconds(lengthRamper.getUIValue());
            case StutterParameterPitch:
                return pitchRamper.getUIValue();
            default:
                std::cout << "Getting unknown parameter" << std::endl;
                abort();
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
        switch (address) {
            case StutterParameterEnable:
                enableRamper.startRamp(value, duration);
                break;
            case StutterParameterLength:
                lengthRamper.startRamp(clamp(secondsFromMS(value), 0.001f, 2.0f), duration); // TODO: Use min and max constants
                break;
            case StutterParameterPitch:
                pitchRamper.startRamp(clamp(value, StutterMinPitchAsRatio, StutterMaxPitchAsRatio), duration);
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
        pitchRamper.dezipperCheck(dezipperRampDuration);
        
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            
            // not ramping
            bool enableParameter = double(enableRamper.getAndStep()) > 0.0;
            double lengthParameter = double(lengthRamper.getAndStep());
            double pitchParameter = double(pitchRamper.getAndStep());
            
            // set mode for current frame
            switch (enableStateTracker.hasStateChanged(enableParameter)) {
                case BoolStateChangeResultUnchanged:
                    // tumbleweed
                    break;
                case BoolStateChangeResultEnabled:
                    // stutter has just been enabled. reset buffers to 0 and set mode to record
                    for(std::size_t i=0; i<buffers.size(); ++i) {
                        buffers[i]->reset();
                    }
                    stutterState = StutterStateRecord;
                    break;
                case BoolStateChangeResultDisabled:
                    // stutter has just been disabled. set mode back to passthrough
                    stutterState = StutterStatePassthrough;
                    break;
            }
            
            int frameOffset = int(frameIndex + bufferOffset);
            
            for (int channel = 0; channel < channelCount; ++channel) {
                
                VarispeedCircularBuffer *buffer = buffers[channel];
                
                float* in = (float*)inBufferListPtr->mBuffers[channel].mData + frameOffset;
                float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                switch (stutterState) {
                    case StutterStatePassthrough:
                        *out = *in;
                        break;
                    case StutterStateRecord:
                        buffer->nextAtRecordHead(*in);
                        [[fallthrough]];
                    case StutterStatePlayback:
                        // TODO: Expensive
                        buffer->playbackLength = int(lengthParameter * sampleRate * channelCount);
                        if (buffer->playbackWrapCount == 0) {
                            // playback normal speed on first wrap
                            *out = buffer->nextAtPlayhead(1.0);
                        } else {
                            *out = buffer->nextAtPlayhead(pitchParameter);
                            // after one wrap, the buffer no longer needs to record
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
    ParameterRamper pitchRamper = {1}; // pitch as ratio
    AUAudioFrameCount dezipperRampDuration;
    std::vector<VarispeedCircularBuffer*> buffers;
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
