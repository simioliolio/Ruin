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
    private var currentPlayer: AVAudioPlayerNode?
    var effectOne: AVAudioNode?
    
    init() { }
    
    func setup(desc: AudioComponentDescription, completion: @escaping ()->()) {
        
        AVAudioUnit.instantiate(with: desc, options: []) { (audioUnit, error) in
            
            if let uwError = error {
                fatalError("Error getting audio unit with desc: \(desc), error: \(uwError)")
            }
            
            guard let audioUnit = audioUnit else {
                fatalError("Audio unit nil when error is nil")
            }
            
            self.engine.attach(audioUnit)
            self.engine.connect(audioUnit, to: self.engine.mainMixerNode, format: nil)
            self.effectOne = audioUnit // keep reference
            completion()
        }
    }
    
    func load(audioFile url: URL) throws {
        
        guard let effectOne = effectOne else { fatalError("setup not called before trying to loading audio file") } // TODO: Throw
        
        let audioFile = try AVAudioFile(forReading: url)
        if let currentPlayer = currentPlayer {
            currentPlayer.stop()
            engine.disconnectNodeOutput(currentPlayer)
            engine.detach(currentPlayer)
            self.currentPlayer = nil
        }
        let newPlayer = AVAudioPlayerNode()
        engine.attach(newPlayer)
        engine.connect(newPlayer, to: effectOne, format: audioFile.processingFormat)
        if !engine.isRunning { try engine.start() }
        newPlayer.scheduleFile(audioFile, at: nil) {
            print("complete!")
        }
        self.currentPlayer = newPlayer
    }
    
    func play() {
        
        currentPlayer?.play(at: nil)
    }
    
    lazy var availableAudioUnitComponents: [AVAudioUnitComponent] = {
        
        let hyperBarnAUDescription = AudioComponentDescription(componentType: kAudioUnitType_Effect, componentSubType: 0, componentManufacturer: 0x68797062, componentFlags: 0, componentFlagsMask: 0)
        return AVAudioUnitComponentManager.shared().components(matching: hyperBarnAUDescription) // slow
    }()
    
}
