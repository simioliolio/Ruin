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

public typealias ReduxReducer<AppState: ReduxState> = (_ action: ReduxAction, _ state: AppState) -> AppState

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
    
    public private(set) var state: AppState
    
    typealias SubscribedState = AppState
    
    private let reducer: ReduxReducer<AppState>
    private var subscribers: [ReduxAnyStoreSubscriber<AppState>] = []
    private var middlewares: [ReduxAnyMiddleware<AppState>] = []
    private let dispatchQueue = DispatchQueue(label: "ReduxStore Action Queue", qos: .default)
    
    init(reducer: @escaping ReduxReducer<AppState>, state: AppState) {
        self.reducer = reducer
        self.state = state
    }
    
    public func dispatchAction(_ action: ReduxAction) {
        dispatchQueue.async {
            self.middlewares.forEach { $0.action(action, state: self.state) }
            self.state = self.reducer(action, self.state)
            self.subscribers.forEach { $0.newState(self.state) }
        }
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
    
    public static func combine(reducers: [ReduxReducer<AppState>]) -> ReduxReducer<AppState> {
        return { action, state in
            reducers.reduce(state) { (resultState: AppState, reducer: ReduxReducer<AppState>) -> AppState in
                return reducer(action, resultState)
            }
        }
    }
}

public class ReduxObservable<AppState: ReduxState, Substate: Equatable> {
    
    public let id = UUID().uuidString
    
    private let transformation: (AppState) -> Substate
    private var unsubscribe: (() -> ())?
    private var lastSubstate: Substate?
    private var onChange: ((Substate) -> ())?
    private var shouldUnsubscribeAfterUpdate = false
    
    @discardableResult
    public init(transformation: @escaping (AppState) -> Substate) {
        self.transformation = transformation
    }
    
    @discardableResult
    public func subscribe(on store: ReduxStore<AppState>) -> Self {
        store.subscribe(self)
        unsubscribe = {
            store.unsubscribe(self)
        }
        return self
    }
    
    @discardableResult
    public func onChange(currentState: AppState, onChange: @escaping (Substate) -> ()) -> Self {
        self.lastSubstate = transformation(currentState)
        self.onChange = onChange
        return self
    }
    
    @discardableResult
    public func thenUnsubscribe() -> Self {
        shouldUnsubscribeAfterUpdate = true
        return self
    }
    
    @discardableResult
    public func dispose(by bag: ReduxDisposeBag) -> Self {
        bag.add(disposable: self)
        return self
    }
}

extension ReduxObservable: ReduxStoreSubscriber {
    
    public typealias SubscribedState = AppState
    
    public func newState(_ state: SubscribedState) {
        
        let currentSubstate = transformation(state)
        
        if lastSubstate != currentSubstate {
            onChange?(currentSubstate)
        }
        
        self.lastSubstate = currentSubstate
        
        if shouldUnsubscribeAfterUpdate {
            unsubscribe?()
        }
    }
    
    public static func == (lhs: ReduxObservable, rhs: ReduxObservable) -> Bool {
        lhs.id == rhs.id
    }
}

extension ReduxObservable: ReduxDisposable {
    
    public func dispose() {
        unsubscribe?()
    }
}

public protocol ReduxDisposable {
    
    func dispose()
}

public class ReduxDisposeBag {
    
    public init() { }
    
    private var disposables: [ReduxDisposable] = []
    
    func add(disposable: ReduxDisposable) {
        disposables.append(disposable)
    }
    
    deinit {
        disposables.forEach { $0.dispose() }
    }
}
