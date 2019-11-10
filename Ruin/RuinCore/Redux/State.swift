//
//  RUState.swift
//  RuinCore
//
//  Created by Simon Haycock on 31/10/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AVFoundation

public struct State: ReduxState {
    
    // UI
    public var choosingPosition: Bool = false
    
    // Audio engine
    public var isPlaying: Bool = false
    public var currentPlaybackPosition: TimeInterval = 0 // unused
    public var audioFileLength: TimeInterval = 0
    public var audioFileFrames: AVAudioFramePosition = 0
}
