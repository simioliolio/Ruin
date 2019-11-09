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
            
            var newState = state ?? State()
            
            switch action {

            case let action as AudioPlayerPlaybackStatusAction:
                newState.isPlaying = action.playing
                break
                
            default:
                print("un-reduced action")
            }
            
            return newState
        }
    }
}
