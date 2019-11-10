//
//  Store.swift
//  RuinCore
//
//  Created by Simon Haycock on 31/10/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

public class Store {
    
    public static let shared = Store()
    
    public let store: ReduxStore<State>
    let reducer: ReduxReducer<State>
    
    public init() {
        
        // Combine more reducers here
        reducer = Store.combine(reducers: [TransportReducer.reduce,
                                           AudioReducer.reduce])
        
        store = ReduxStore<State>(reducer: reducer, state: State())
    }
    
    public func dispatchAction(_ action: ReduxAction) {
        store.dispatchAction(action)
    }
}

extension Store {
    
    static func combine(reducers: [Reducer]) -> Reducer {
        return { action, state in
            
            reducers.reduce(state) { (resultState: State, reducer: Reducer) -> State in
                return reducer(action, resultState)
            }
        }
    }
}
