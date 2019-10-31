//
//  Redux.swift
//  Ruin
//
//  Created by Simon Haycock on 10/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

public protocol ReduxAction {}

public protocol ReduxState {}

typealias ReduxReducer<AppState: ReduxState> = (_ action: ReduxAction, _ state: AppState?) -> AppState

public protocol ReduxStoreSubscriber {
    associatedtype SubscribedState: ReduxState
    func newState(_ state: SubscribedState)
}

struct ReduxAnyStoreSubscriber<AppState: ReduxState>: ReduxStoreSubscriber {
    
    typealias SubscribedState = AppState
    let subscription: (SubscribedState) -> ()
    
    init<Base: ReduxStoreSubscriber>(_ base: Base) where Base.SubscribedState == AppState {
        subscription = base.newState
    }
    
    func newState(_ state: AppState) {
        subscription(state)
    }
}

public class ReduxStore<AppState: ReduxState> {
    
    typealias SubscribedState = AppState
    
    let reducer: ReduxReducer<AppState>
    var state: AppState?
    var subscribers: [ReduxAnyStoreSubscriber<AppState>] = []
    
    init(reducer: @escaping ReduxReducer<AppState>, state: AppState?) {
        self.reducer = reducer
        self.state = state
    }
    
    public func dispatchAction(_ action: ReduxAction) {
        state = reducer(action, state)
        guard state != nil else { fatalError("State nil after action!") }
        subscribers.forEach { $0.newState(state!) }
    }
    
    public func subscribe<Subscriber: ReduxStoreSubscriber>(_ newSubscriber: Subscriber) where Subscriber.SubscribedState == AppState {
        subscribers.append(ReduxAnyStoreSubscriber(newSubscriber))
    }
}

