//
//  RuinStutterAudioUnitViewController+Factory.swift
//  RuinStutterAU-iOS
//
//  Created by Simon Haycock on 06/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import RuinStutterFramework_iOS

extension RuinStutterAudioUnitViewController: AUAudioUnitFactory {
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try RuinStutterAudioUnit(componentDescription: componentDescription, options: [])
        if isViewLoaded {
            connectUI(to: audioUnit!)
        }
        return audioUnit!
    }
    
    
}
