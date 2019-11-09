//
//  RUState.swift
//  RuinCore
//
//  Created by Simon Haycock on 31/10/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

public struct State: ReduxState {
    
    // Audio engine
    public var isPlaying: Bool = false
    public var currentPlaybackPosition: TimeInterval = 0
    public var audioFileLength: TimeInterval = 0
}
