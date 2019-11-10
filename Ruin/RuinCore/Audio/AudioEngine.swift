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
    
    public func setup(effect: AVAudioNode) {
        
        self.effectOne = effect
        
        engine.attach(effect)
        engine.attach(player.player)
        engine.connect(effect, to: engine.mainMixerNode, format: nil)
        engine.connect(player.player, to: effect, format: nil)

        if !self.engine.isRunning {
            do {
                try self.engine.start()
                delegate?.didStartAudioEngine()
            } catch {
                delegate?.didFailToStartAudioEngine()
            }
        }
    }
    
    func applyNewProcessingFormat(_ format: AVAudioFormat) {
        guard let effect = effectOne else { fatalError("no effect to connect") }
        engine.disconnectNodeOutput(player.player)
        engine.disconnectNodeOutput(effect)
        engine.connect(effect, to: engine.mainMixerNode, format: format)
        engine.connect(player.player, to: effect, format: format)
    }
}
