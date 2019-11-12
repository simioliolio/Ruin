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
    
    let store: ReduxStore<State>
    let reducer: ReduxReducer<State>
    
    private let dispatchQueue = DispatchQueue(label: "Store Action Queue", qos: .default)
    
    public init() {
        
        // Combine more reducers here
        reducer = Store.combine(reducers: [TransportReducer.reduce,
                                           AudioReducer.reduce])
        
        store = ReduxStore<State>(reducer: reducer, state: State())
    }
    
    public func dispatchAction(_ action: ReduxAction) {
        dispatchQueue.async {
            self.store.dispatchAction(action)
        }
    }
    
    public func subscribe<Subscriber: ReduxStoreSubscriber>(_ newSubscriber: Subscriber) where Subscriber.SubscribedState == State {
        store.subscribe(newSubscriber)
    }
    
    public func unsubscribe<Subscriber: ReduxStoreSubscriber>(_ subscriber: Subscriber) where Subscriber.SubscribedState == State {
        store.unsubscribe(subscriber)
    }
    
    public func subscribe<Middleware: ReduxMiddleware>(_ middleware: Middleware) where Middleware.SubscribedState == State {
        store.subscribe(middleware)
    }
    
    public func unsubscribe<Middleware: ReduxMiddleware>(_ middleware: Middleware) where Middleware.SubscribedState == State {
        store.unsubscribe(middleware)
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
