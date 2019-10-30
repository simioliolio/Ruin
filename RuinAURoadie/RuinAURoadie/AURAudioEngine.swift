//
//  AURAudioEngine.swift
//
//  Created by Simon Haycock on 27/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AVFoundation

// Ruin's audio engine has an audio player and three effect slots.
final public class AURAudioEngine {
    
    private let engine = AVAudioEngine()
    private var player: AVAudioPlayerNode?
    private var audioFileFormat: AVAudioFormat?
    public var effectOne: AVAudioNode?
    
    public init() { }
    
    public func setup(desc: AudioComponentDescription, completion: @escaping (AVAudioUnit?)->()) {
        
        if let currentEffectOne = effectOne {
            engine.disconnectNodeOutput(currentEffectOne)
            engine.disconnectNodeInput(currentEffectOne)
            engine.detach(currentEffectOne)
            if let currentPlayer = player {
                // reconnect the player to the mixer while effect is instantiated
                engine.connect(currentPlayer, to: engine.mainMixerNode, format: audioFileFormat)
            }
        }
        
        AVAudioUnit.instantiate(with: desc, options: []) { (audioUnit, error) in
            
            if let uwError = error {
                fatalError("Error getting audio unit with desc: \(desc), error: \(uwError)")
            }
            
            guard let audioUnit = audioUnit else {
                fatalError("Audio unit nil when error is nil")
            }
            
            self.engine.attach(audioUnit)
            self.engine.connect(audioUnit, to: self.engine.mainMixerNode, format: nil)
            
            if let currentPlayer = self.player {
                self.engine.connect(currentPlayer, to: audioUnit, format: self.audioFileFormat)
            }
            
            self.effectOne = audioUnit // keep reference
            completion(audioUnit)
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
