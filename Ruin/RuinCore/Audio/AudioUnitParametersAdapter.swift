//
//  AudioUnitParametersAdapter.swift
//  RuinCore
//
//  Created by Simon Haycock on 10/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AudioUnit

class AudioUnitParametersAdapter {
    
    enum Input {
        case enabled
        case x
        case y
    }
    
    let audioUnitInterface: AudioUnitInterface
    let inputToAddressRoute: [Input: AUParameterAddress]
    
    init(audioUnitInterface: AudioUnitInterface, inputToAddressRoute: [Input: AUParameterAddress]) {
        self.audioUnitInterface = audioUnitInterface
        self.inputToAddressRoute = inputToAddressRoute
    }
    
    func route(enabled: Bool, x: Float, y: Float) {
        
        // Implementation assumes that audioUnitInterface has ordered parameters by address
        
        if let parameterAddress = inputToAddressRoute[.enabled] {
            let destinationParameter = audioUnitInterface.parameters[Int(parameterAddress)]
            destinationParameter.value = enabled ? destinationParameter.maxValue : destinationParameter.minValue
        }
        
        route(inputType: .x, input: x)
        route(inputType: .y, input: y)
    }
    
    private func route(inputType: Input, input: Float) {
        
        if let parameterAddress = inputToAddressRoute[inputType] {
            let destinationParameter = audioUnitInterface.parameters[Int(parameterAddress)]
            let newValue = destinationParameter.minValue + (input * destinationParameter.maxValue - destinationParameter.minValue)
            destinationParameter.value = newValue
        }
    }
}
