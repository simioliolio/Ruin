//
//  AudioEngineEffectLoadAction.swift
//  RuinCore
//
//  Created by Simon Haycock on 11/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AudioUnit

public struct AudioEngineEffectLoadAction: ReduxAction {
    
    public let effect: AUAudioUnit
    public let index: Int
    
    public init(effect: AUAudioUnit, index: Int) {
        self.effect = effect
        self.index = index
    }
}
