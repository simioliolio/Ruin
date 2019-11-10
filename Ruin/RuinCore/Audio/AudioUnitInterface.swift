//
//  AudioUnitInterface.swift
//  RuinCore
//
//  Created by Simon Haycock on 10/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AudioToolbox

// TODO: Move to AURoadie?
class AudioUnitInterface {
    
    let parameters: [AUParameter]
    private let parameterTree: AUParameterTree
    private var observeToken: AUParameterObserverToken?
    
    init(audioUnit: AUAudioUnit) {
        guard let auParameterTree = audioUnit.parameterTree else {
            fatalError("No parameter tree for audio unit \(audioUnit.audioUnitName ?? "Unknown name")")
        }
        parameterTree = auParameterTree
        parameters = auParameterTree.allParameters.sorted { $0.address < $1.address }
        observeToken = auParameterTree.token(byAddingParameterObserver: parameterUpdated)
    }
    
    func parameterUpdated(address: AUParameterAddress, value: AUValue) {
        // TODO: Call a closure?1
    }
    
    deinit {
        if let observeToken = observeToken {
            parameterTree.removeParameterObserver(observeToken)
        }
    }
}
