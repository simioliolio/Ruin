//
//  AURAudioEngine.swift
//
//  Created by Simon Haycock on 27/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: - AURAudioEngine

/**
 An audio engine for use during audio unit development.
*/
final public class AURAudioEngine {
    
    private let engine = AVAudioEngine()
    private var player: AVAudioPlayerNode?
    private var audioFileFormat: AVAudioFormat?
    public var effectOne: AVAudioNode?
    public var effectTwo: AVAudioNode?
    public var effectThree: AVAudioNode?
    
    public init() { }
    
    public func setup(component: AudioComponentDescription, at position: EffectPosition, completion: @escaping ()->()) {
        
        var nodeBeingModified = node(at: position)
        
        // Replace an existing node
        if let existingNode = nodeBeingModified {
            if existingNode.numberOfInputs > 0 {
                engine.disconnectNodeInput(existingNode)
            }
            if existingNode.numberOfOutputs > 0 {
                engine.disconnectNodeOutput(existingNode)
            }
            engine.detach(existingNode)
        }
        
        AVAudioUnit.instantiate(with: component, options: []) { (audioUnit, error) in
            
            if let uwError = error {
                fatalError("Error getting audio unit with desc: \(component), error: \(uwError)")
            }
            
            guard let audioUnit = audioUnit else {
                fatalError("Audio unit nil when error is nil")
            }
            
            self.engine.attach(audioUnit)
            guard let outputNode = self.outputNode(for: position) else {
                fatalError("No output node for position \(position)")
            }
            self.engine.connect(audioUnit, to: outputNode, format: self.audioFileFormat)
            
            if let currentPlayer = self.player {
                if currentPlayer.numberOfOutputs == 0 {
                    // Player has been disconnected by change in effect chain
                    self.engine.connect(currentPlayer, to: self.firstEffectNode!, format: self.audioFileFormat)
                }
            }
            
            nodeBeingModified = audioUnit // keep reference
            completion()
        }
    }
    
    public func load(audioFile url: URL) throws {
        
        guard let effectOne = effectOne else { fatalError("setup not called before trying to loading audio file") } // TODO: Throw
        
        let audioFile = try AVAudioFile(forReading: url)
        let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))!
        try! audioFile.read(into: audioFileBuffer)
        
        if let currentPlayer = player {
            currentPlayer.stop()
            engine.disconnectNodeOutput(currentPlayer)
            engine.detach(currentPlayer)
            self.player = nil
        }
        let newPlayer = AVAudioPlayerNode()
        engine.attach(newPlayer)
        engine.connect(newPlayer, to: effectOne, format: audioFile.processingFormat)
        if !engine.isRunning {
            try engine.start()
            
        }
        newPlayer.scheduleBuffer(audioFileBuffer, at: nil, options: .loops, completionHandler: nil)
        player = newPlayer
        audioFileFormat = audioFile.processingFormat
    }
    
    public func play() {
        player?.play(at: nil)
    }
    
    lazy var availableAudioUnitComponents: [AVAudioUnitComponent] = {
        
        let hyperBarnAUDescription = AudioComponentDescription(componentType: kAudioUnitType_Effect, componentSubType: 0, componentManufacturer: 0x68797062, componentFlags: 0, componentFlagsMask: 0)
        return AVAudioUnitComponentManager.shared().components(matching: hyperBarnAUDescription) // slow
    }()
    
}

// MARK: - Routing
extension AURAudioEngine {
    
    public enum EffectPosition {
        case one
        case two
        case three
    }
    
    private func node(at position: EffectPosition) -> AVAudioNode? {
        switch position {
        case .one:
            return effectOne
        case .two:
            return effectTwo
        case .three:
            return effectThree
        }
    }
    
    private func outputNode(for position: EffectPosition) -> AVAudioNode? {
        switch position {
        case .one:
            return effectTwo
        case .two:
            return effectThree
        case .three:
            return engine.mainMixerNode
        }
    }
    
    private func inputNode(for position: EffectPosition) -> AVAudioNode? {
        switch position {
        case .one:
            return player
        case .two:
            return effectOne
        case .three:
            return effectTwo
        }
    }
    
    private var firstEffectNode: AVAudioNode? {
        if effectOne != nil {
            return effectOne
        } else if effectTwo != nil {
            return effectTwo
        } else if effectThree != nil {
            return effectThree
        }
        return nil
    }
}
