//
//  XyControlAction.swift
//  RuinCore
//
//  Created by Simon Haycock on 09/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

public struct XyControlAction: ReduxAction {
    
    public let index: Int
    public let activated: Bool
    public let position: CGPoint
    
    public init(index: Int, activated: Bool, position: CGPoint) {
        self.index = index
        self.activated = activated
        self.position = position
    }
}
