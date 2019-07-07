//
//  RUAudioUnitFactory.swift
//  RuinCore
//
//  Created by Simon Haycock on 28/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AVFoundation

final class RUAudioUnitFactory {
    
    enum AudioUnitsError: Error {
        case noResults
    }
    
    // TODO: Completion with simple error
    static func audioUnits(from components: [AVAudioUnitComponent], completion: @escaping (Result<[AVAudioUnit], Error>)->()) {
        
        let dispatchGroup = DispatchGroup()
        
        var results: [AVAudioUnit] = []
        var errors: [String: Error] = [:]
        
        components.forEach { audioUnitComponent in
            dispatchGroup.enter()
            AVAudioUnit.instantiate(with: audioUnitComponent.audioComponentDescription, options: []) { (audioUnit, error) in
                guard let audioUnit = audioUnit else {
                    errors[audioUnitComponent.name] = error
                    dispatchGroup.leave()
                    return
                }
                results.append(audioUnit)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
        
        guard errors.count == 0 else { completion(Result.failure(errors)); return }
        guard results.count > 0 else { completion(Result.failure(AudioUnitsError.noResults)); return }
        completion(Result.success(results))
    }
}

extension Dictionary: Error where Key == String, Value == Error {
    
    var localizedDescription: String {
        return map { "\($0), \($1.localizedDescription)"}.reduce("", { $0 + "\n" + $1 })
    }
}
