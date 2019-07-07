//
//  RuinStutterAUViewController+Factory.swift
//  RuinStutterAU-macOS
//
//  Created by Simon Haycock on 07/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import RuinStutterFramework_macOS

extension RuinStutterAUViewController: AUAudioUnitFactory {
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try RuinStutterAudioUnit(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }
    
}
