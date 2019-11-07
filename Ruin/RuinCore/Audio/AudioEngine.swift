//
//  AudioEngine.swift
//  RuinCore
//
//  Created by Simon Haycock on 05/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AVFoundation
import RuinStutterFramework_iOS

protocol AudioEngineDelegate: class {
    func didStartAudioEngine()
    func didFailToStartAudioEngine()
}

/// The 'raw' audio guts
final public class AudioEngine {
    
    let player: AudioPlayer
    var effectOne: AVAudioNode?
    let audioUnitComponentLibrary = AudioUnitComponentLibrary()
    let engine = AVAudioEngine()
    weak var delegate: AudioEngineDelegate?
    
    public init(player: AudioPlayer) {
        self.player = player
    }
    
    public func setup() throws {
        
        audioUnitComponentLibrary.refresh {
            
            // TODO: Handle loading three effects
            let stutterComponent = self.audioUnitComponentLibrary.components.first(where: {$0.name == "Stutter" })!
            AVAudioUnit.instantiate(with: stutterComponent.audioComponentDescription, options: []) { (stutterNode, error) in
                
                guard error == nil else {
                    fatalError("Error instantiating stutter node") // TODO: Throw
                }
                
                self.effectOne = stutterNode
                self.attachAndConnect()
            }
        }
    }
    
    private func attachAndConnect() {
        
        guard let effect = effectOne else { fatalError("no effect to connect") }
        
        engine.attach(effect)
        engine.attach(player.player)
        engine.connect(effect, to: engine.mainMixerNode, format: nil)
        engine.connect(player.player, to: effect, format: nil)

        if !self.engine.isRunning {
            try? self.engine.start()
            delegate?.didStartAudioEngine()
        }
    }
}
