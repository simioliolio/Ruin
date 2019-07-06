//
//  RURedux.swift
//  Ruin
//
//  Created by Simon Haycock on 13/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
    
public struct RUState: State {
    public var playing: Bool = false
}

public struct RUTogglePlaybackAction: Action {
    public init() { }
}

public class RUStore {
    
    public static let shared = RUStore()
    
    public let store: Store<RUState>
    let reducer: Reducer<RUState>
    
    public init() {
        
        reducer = { action, state in
            
            var newState = state ?? RUState()
            
            switch action {
            case _ as RUTogglePlaybackAction:
                newState.playing = !newState.playing
            default:
                fatalError("unknown action")
            }
            
            return newState
            
        }
        
        store = Store<RUState>(reducer: reducer, state: nil)
    }
    
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
}



