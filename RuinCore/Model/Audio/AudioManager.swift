//
//  AudioManager.swift
//  RuinCore
//
//  Created by Simon Haycock on 17/06/2018.
//  Copyright © 2018 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AudioKit

public class AudioManager {
    
    public init() {
        
        let oscillator = AKOscillator(waveform: AKTable(.sine, phase: 0, count: 512), frequency: 1000, amplitude: 0.8, detuningOffset: 0, detuningMultiplier: 0)
        AudioKit.output = oscillator
        
        do {
            try AudioKit.start()
            oscillator.start()
        } catch {
            fatalError("could not start audio engine. error: \(error)")
        }
        
        
        
    }
    
}
