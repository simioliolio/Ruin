//
//  RUState.swift
//  RuinCore
//
//  Created by Simon Haycock on 31/10/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

public struct State: ReduxState {
    // Interactions
    public var positionInteraction: SliderInteractionState = SliderInteractionState()
    public var xYInteractionState: (
        left: XYInteractionState,
        middle: XYInteractionState,
        right: XYInteractionState) = (XYInteractionState(),
                                      XYInteractionState(),
                                      XYInteractionState())
    // Audio engine
    public var isPlaying: Bool = false
    public var currentPlaybackPosition: TimeInterval = 0
    public var audioFileLength: TimeInterval = 0
        
}

public struct SliderInteractionState {
    public var position: CGFloat = 0.0
    public var enabled: Bool = false
    public var previouslyEnabled: Bool = false
}

public struct XYInteractionState {
    public var position: CGPoint = CGPoint(x: 0.5, y: 0.5)
    public var enabled: Bool = false
}
