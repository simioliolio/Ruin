//
//  AudioReducer.swift
//  RuinCore
//
//  Created by Simon Haycock on 10/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

struct AudioReducer {
    
    static var reduce: Reducer {
        
        return { action, state in
            
            var newState = state
            
            switch action {
                
            case let action as AudioPlayerFileLoadAction:
                newState.audioFileLength = (1 / action.processingFormat.sampleRate) * Double(action.length)
                newState.audioFileFrames = action.length
                
            default:
                print("unhandled action \(action)")
            }
            
            return newState
        }
    }
}
