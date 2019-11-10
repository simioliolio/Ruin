//
//  PositionChangeAction.swift
//  RuinCore
//
//  Created by Simon Haycock on 10/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

public struct PositionChangeAction: ReduxAction {
    
    public let choosing: Bool
    public let positionAsPercentage: Float
    
    public init(choosing: Bool, positionAsPercentage: Float) {
        self.choosing = choosing
        self.positionAsPercentage = positionAsPercentage
    }
}
