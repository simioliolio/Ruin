//
//  RURedux.swift
//  Ruin
//
//  Created by Simon Haycock on 13/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
    
struct RUState: State {
    var playing: Bool = false
}

struct RUTogglePlaybackAction: Action {}

let store = Store<RUState>(reducer: appReducer, state: nil)

func appReducer(_ action: Action, _ state: RUState?) -> RUState {
    
    var newState = state ?? RUState()
    
    switch action {
    case _ as RUTogglePlaybackAction:
        newState.playing = !newState.playing
    default:
        fatalError("unknown action")
    }
    
    return newState
}

