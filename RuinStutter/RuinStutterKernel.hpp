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
class RuinStutterKernel : DSPKernel {
    
public:
    
    RuinStutterKernel() {}
    
    void init() {
        
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
#warning Unimplemented!
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
#warning Unimplemented!
    }
    
    void handleMIDIEvent(AUMIDIEvent const& midiEvent) {
#warning Unimplemented!
    }
    
    void processWithEvents(AudioTimeStamp const* timestamp, AUAudioFrameCount frameCount, AURenderEvent const* events) {
        
    }
    
    
    
private:
    
    
};

#endif /* RuinStutterKernel_h */
