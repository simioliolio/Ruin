//
//  RuinBypassAUViewController.swift
//  RuinBypassAU-macOS
//
//  Created by Simon Haycock on 28/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import CoreAudioKit
import RuinBypassFramework_macOS

extension RuinBypassAUViewController: AUAudioUnitFactory {
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try RuinBypassAudioUnit(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }
    
}
