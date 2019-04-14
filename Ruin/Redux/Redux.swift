//
//  Redux.swift
//  Ruin
//
//  Created by Simon Haycock on 10/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

protocol Action {}

protocol State {}

typealias Reducer<AppState: State> = (_ action: Action, _ state: AppState?) -> AppState

protocol StoreSubscriber {
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

enum StoreSubscriberWrapper<T: StoreSubscriber> {
    case subscriber(T)
}

class Store<AppState: State> {
    
    typealias SubscribedState = AppState
    
    let reducer: Reducer<AppState>
    var state: AppState?
    var subscribers: [AnyStoreSubscriber<AppState>] = []
    
    init(reducer: @escaping Reducer<AppState>, state: AppState?) {
        self.reducer = reducer
        self.state = state
    }
    
    func dispatchAction(_ action: Action) {
        state = reducer(action, state)
        guard state != nil else { fatalError("State nil after action!") }
        subscribers.forEach { $0.newState(state!) }
    }
    
    func subscribe<Subscriber: StoreSubscriber>(_ newSubscriber: Subscriber) where Subscriber.SubscribedState == AppState {
        subscribers.append(AnyStoreSubscriber(newSubscriber))
    }
}

