//
//  RUAudioEngine.swift
//  RuinCore
//
//  Created by Simon Haycock on 27/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AVFoundation

// Ruin's audio engine has an audio player and three effect slots.
final public class RUAudioEngine {
    
    private let engine = AVAudioEngine()
    private var currentPlayer: AVAudioPlayerNode?
    var effectOne: AVAudioNode?
    
    init() { }
    
    func setup(completion: @escaping ()->()) {
        
        // instantiate initial effects
        DispatchQueue.global(qos: .default).async {
            
            RUAudioUnitFactory.audioUnits(from: self.availableAudioUnitComponents) { result in
                
                switch result {
                case .failure(let error):
                    fatalError("Could not get audio units from audio unit components. Error: \(error)")
                case .success(let audioUnits):
                    guard let effectOne = audioUnits.first(where: { $0.manufacturerName == "RuinStutterAU-iOS" }) else {
                        fatalError("Stutter audio unit not found")
                    }
                    self.engine.attach(effectOne)
                    self.engine.connect(effectOne, to: self.engine.mainMixerNode, format: nil)
                    self.effectOne = effectOne // keep reference
                    completion()
                }
            }
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
