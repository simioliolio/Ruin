//
//  AURComponentDescriptionProviding.swift
//  RuinAURoadie
//
//  Created by Simon Haycock on 28/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AudioToolbox

public protocol AURComponentDescriptionProviding {
    static var componentDescription: AudioComponentDescription { get }
    static var componentName: String { get }
}
