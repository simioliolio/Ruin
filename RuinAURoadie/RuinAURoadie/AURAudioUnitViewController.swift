//
//  AURAudioUnitViewController.swift
//  RuinAURoadie
//
//  Created by Simon Haycock on 28/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AudioUnit

public protocol AURAudioUnitViewController {
    var audioUnit: AUAudioUnit? { get set }
}
