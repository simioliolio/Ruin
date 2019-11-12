//
//  TransportReducer.swift
//  RuinCore
//
//  Created by Simon Haycock on 31/10/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

struct TransportReducer {
    
    static var reduce: Reducer {
        
        return { action, state in
            
            var newState = state
            
            switch action {

            case let action as AudioPlayerPlaybackStatusAction:
                newState.isPlaying = action.playing
                break
                
            case let action as PositionChangeAction:
                newState.choosingPosition = action.choosing
                
            default:
                break
            }
            
            return newState
        }
    }
}
