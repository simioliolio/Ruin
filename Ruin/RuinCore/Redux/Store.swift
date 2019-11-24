//
//  Store.swift
//  RuinCore
//
//  Created by Simon Haycock on 31/10/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

public class Store {
    
    public static let shared: ReduxStore<State> = {
        let reducers = [TransportReducer.reduce,
                        AudioReducer.reduce]
        let reducer = ReduxStore<State>.combine(reducers: reducers)
        return ReduxStore<State>(reducer: reducer,
                                 state: State())
    }()
}
