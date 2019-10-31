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
        reducer = TransportReducer.reduce
        
        store = ReduxStore<State>(reducer: reducer, state: nil)
    }
    
    public func dispatchAction(_ action: ReduxAction) {
        store.dispatchAction(action)
    }
}
