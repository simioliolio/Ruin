//
//  SimpleRedux.swift
//  Ruin
//
//  Created by Simon Haycock on 10/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

protocol Action {}

protocol State {}

typealias Reducer = (_ action: Action, _ state: State?) -> State

protocol StoreSubscriber {
    func newState(_ state: State)
}


class Store {
    
    let reducer: Reducer
    var state: State?
    var subscribers: [StoreSubscriber] = []
    
    init(reducer: @escaping Reducer, state: State?) {
        self.reducer = reducer
        self.state = state
    }
    
    func dispatchAction(_ action: Action) {
        state = reducer(action, state)
        guard state != nil else { fatalError("State nil after action!") }
        subscribers.forEach { $0.newState(state!) }
    }
    
    func subscribe(_ newSubscriber: StoreSubscriber) {
        subscribers.append(newSubscriber)
    }
}

