//
//  AudioUnitComponentLibrary.swift
//  RuinCore
//
//  Created by Simon Haycock on 07/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AVFoundation
import RuinStutterFramework_iOS

class AudioUnitComponentLibrary {
    
    var components: [AVAudioUnitComponent] = []
    
    func refresh(completion: @escaping ()->()) {
        
        registerRuinAudioUnits()
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            
            guard let self = self else { return }
            
            let components = AVAudioUnitComponentManager.shared().components(matching: self.hypbEffectComponentDescription)
            self.components = components
            
            completion()
        }
    }
    
    private func registerRuinAudioUnits() {
        
        AUAudioUnit.registerSubclass(RuinStutterAudioUnit.self, as: hypbEffectComponentDescription, name: "Stutter", version: 999)
    }
    
    var hypbEffectComponentDescription: AudioComponentDescription {
        return AudioComponentDescription(componentType: kAudioUnitType_Effect,
                                         componentSubType: 0,
                                         componentManufacturer: 0x48797063 /*'Hypb'*/,
                                         componentFlags: 0,
                                         componentFlagsMask: 0)
    }
}
