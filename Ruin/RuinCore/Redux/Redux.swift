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

public protocol ReduxStoreSubscriber: Equatable {
    associatedtype SubscribedState: ReduxState
    var id: String { get }
    func newState(_ state: SubscribedState)
}

public protocol ReduxMiddleware: Equatable {
    associatedtype SubscribedState: ReduxState
    var id: String { get }
    func action(_ action: ReduxAction, state: SubscribedState)
}

struct ReduxAnyStoreSubscriber<AppState: ReduxState>: ReduxStoreSubscriber {
    
    typealias SubscribedState = AppState
    let subscription: (SubscribedState) -> ()
    let id: String
    
    init<Base: ReduxStoreSubscriber>(_ base: Base) where Base.SubscribedState == AppState {
        subscription = base.newState
        id = base.id
    }
    
    func newState(_ state: AppState) {
        subscription(state)
    }
    
    static func == (lhs: ReduxAnyStoreSubscriber<AppState>, rhs: ReduxAnyStoreSubscriber<AppState>) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ReduxAnyMiddleware<AppState: ReduxState>: ReduxMiddleware {
    
    typealias SubscribedState = AppState
    let id: String
    let performAction: (ReduxAction, SubscribedState) -> ()
    
    init<Base: ReduxMiddleware>(_ base: Base) where Base.SubscribedState == AppState {
        id = base.id
        performAction = base.action
    }
    
    func action(_ action: ReduxAction, state: AppState) {
        performAction(action, state)
    }
    
    static func == (lhs: ReduxAnyMiddleware<AppState>, rhs: ReduxAnyMiddleware<AppState>) -> Bool {
        return lhs.id == rhs.id
    }
}

public class ReduxStore<AppState: ReduxState> {
    
    typealias SubscribedState = AppState
    
    let reducer: ReduxReducer<AppState>
    var state: AppState?
    var subscribers: [ReduxAnyStoreSubscriber<AppState>] = []
    var middlewares: [ReduxAnyMiddleware<AppState>] = []
    
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
        subscribers = subscribers + [ReduxAnyStoreSubscriber(newSubscriber)]
    }
    
    public func unsubscribe<Subscriber: ReduxStoreSubscriber>(_ subscriber: Subscriber) where Subscriber.SubscribedState == AppState {
        let excludedSubscriber = ReduxAnyStoreSubscriber(subscriber)
        subscribers = subscribers.filter{ $0 != excludedSubscriber }
    }
    
    public func subscribe<Middleware: ReduxMiddleware>(_ middleware: Middleware) where Middleware.SubscribedState == AppState {
        middlewares = middlewares + [ReduxAnyMiddleware(middleware)]
    }
    
    public func unsubscribe<Middleware: ReduxMiddleware>(_ middleware: Middleware) where Middleware.SubscribedState == AppState {
        let excludedMiddleware = ReduxAnyMiddleware(middleware)
        middlewares = middlewares.filter{ $0 != excludedMiddleware }
    }
}

