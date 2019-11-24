//
//  Observable.swift
//  RuinCore
//
//  Created by Simon Haycock on 24/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

public typealias Observable<Substate: Equatable> = ReduxObservable<State, Substate>
