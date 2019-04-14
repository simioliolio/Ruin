//
//  Redux.swift
//  Ruin
//
//  Created by Simon Haycock on 10/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

public protocol Action {}

public protocol State {}

typealias Reducer<AppState: State> = (_ action: Action, _ state: AppState?) -> AppState

public protocol StoreSubscriber {
    associatedtype SubscribedState: State
    func newState(_ state: SubscribedState)
}

struct AnyStoreSubscriber<AppState: State>: StoreSubscriber {
    
    typealias SubscribedState = AppState
    let subscription: (SubscribedState) -> ()
    
    init<Base: StoreSubscriber>(_ base: Base) where Base.SubscribedState == AppState {
        subscription = base.newState
    }
    
    func newState(_ state: AppState) {
        subscription(state)
    }
}

public class Store<AppState: State> {
    
    typealias SubscribedState = AppState
    
    let reducer: Reducer<AppState>
    var state: AppState?
    var subscribers: [AnyStoreSubscriber<AppState>] = []
    
    init(reducer: @escaping Reducer<AppState>, state: AppState?) {
        self.reducer = reducer
        self.state = state
    }
    
    public func dispatchAction(_ action: Action) {
        state = reducer(action, state)
        guard state != nil else { fatalError("State nil after action!") }
        subscribers.forEach { $0.newState(state!) }
    }
    
    public func subscribe<Subscriber: StoreSubscriber>(_ newSubscriber: Subscriber) where Subscriber.SubscribedState == AppState {
        subscribers.append(AnyStoreSubscriber(newSubscriber))
    }
}

