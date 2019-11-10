//
//  AudioNodeFactory.swift
//  RuinCore
//
//  Created by Simon Haycock on 10/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AVFoundation

class AudioNodeFactory {
    
    let audioUnitComponentLibrary = AudioUnitComponentLibrary()
    
    func makeAudioUnitSynchronously(named name: String) -> (AVAudioNode?) {
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        var aquiredNode: AVAudioUnit?
        
        audioUnitComponentLibrary.refresh {
            let stutterComponent = self.audioUnitComponentLibrary.components.first(where: {$0.name == "Stutter" })!
            AVAudioUnit.instantiate(with: stutterComponent.audioComponentDescription, options: []) { (node, error) in
                
                guard error == nil else {
                    fatalError("Error instantiating node: \(String(describing: error))")
                }
                
                aquiredNode = node
                dispatchGroup.leave()
            }
        }
        
        _ = dispatchGroup.wait(timeout: .now() + 5)
        return aquiredNode
    }
    
}
