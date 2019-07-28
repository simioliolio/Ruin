//
//  RuinBypassAU_macOSAudioUnit+AURComponentDescriptionProviding.swift
//  RuinBypassFramework-macOS
//
//  Created by Simon Haycock on 28/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import RuinAURoadie

extension RuinBypassAudioUnit: AURComponentDescriptionProviding {
    
    public static var componentDescription: AudioComponentDescription {
        var desc = AudioComponentDescription()
        desc.componentType = kAudioUnitType_Effect
        desc.componentSubType = 0x64697374 /*'dist'*/
        desc.componentManufacturer = 0x48797062 /*'Hypb'*/
        desc.componentFlags = 0
        desc.componentFlagsMask = 0
        return desc
    }
    
    public static var componentName: String {
        return "Hypb: RuinStutterAU-macOS"
    }
}
