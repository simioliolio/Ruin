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
    private var player = AVAudioPlayerNode()
    public var effectOne: AVAudioNode?
    
    public init() { }
    
    public func setup(desc: AudioComponentDescription, completion: @escaping (AVAudioUnit?)->()) {
        
        if let currentEffectOne = effectOne {
            engine.disconnectNodeOutput(currentEffectOne)
        }
        
        AVAudioUnit.instantiate(with: desc, options: []) { (audioUnit, error) in
            
            if let uwError = error {
                fatalError("Error getting audio unit with desc: \(desc), error: \(uwError)")
            }
            guard let audioUnit = audioUnit else {
                fatalError("Audio unit nil when error is nil")
            }
            
            self.engine.attach(audioUnit)
            if self.player.engine == nil {
                self.engine.attach(self.player)
            }
            self.engine.connect(audioUnit, to: self.engine.mainMixerNode, format: nil)
            self.engine.connect(self.player, to: audioUnit, format: nil)
            
            self.effectOne = audioUnit
            if !self.engine.isRunning {
                try? self.engine.start()
            }
            completion(audioUnit)
        }
    }
    
    public func play(url: URL) throws {
        guard let audioFile = try? AVAudioFile(forReading: url) else { return assertionFailure("could not get av audio file") }
        guard let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length)) else { return assertionFailure("Couldn't make audio buffer from audio file \(audioFile)") } // TODO: Throw
        do {
            try audioFile.read(into: audioFileBuffer) // TODO: Handle unwrap
        } catch {
            fatalError("error: \(error)")
        }
        player.scheduleBuffer(audioFileBuffer, at: nil, options: .loops, completionHandler: nil)
        player.play(at: nil)
    }
    
    lazy var availableAudioUnitComponents: [AVAudioUnitComponent] = {
        
        let hyperBarnAUDescription = AudioComponentDescription(componentType: kAudioUnitType_Effect, componentSubType: 0, componentManufacturer: 0x68797062, componentFlags: 0, componentFlagsMask: 0)
        return AVAudioUnitComponentManager.shared().components(matching: hyperBarnAUDescription) // slow
    }()
    
}
