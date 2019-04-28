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
    private let player = AVAudioPlayerNode()
    var effectOne: AVAudioNode?
    
    init() { }
    
    func setupEffects(completion: @escaping ()->()) {
        
        // instantiate initial effects
        DispatchQueue.global(qos: .default).async {
            
            RUAudioUnitFactory.audioUnits(from: self.availableAudioUnitComponents) { result in
                
                switch result {
                case .failure(let error):
                    fatalError("Could not get audio units from audio unit components. Error: \(error)")
                case .success(let audioUnits):
                    self.effectOne = audioUnits.first(where: { $0.name == "RuinStutter" })!
                    completion()
                }
            }
        }
    }
    
    func load(audioFile url: URL) throws {
        
        let audioFile = try AVAudioFile(forReading: url)
        if player.isPlaying { player.stop() }
        connectAudioGraph(format: audioFile.processingFormat)
        if !engine.isRunning { try engine.start() }
        player.scheduleFile(audioFile, at: nil) {
            print("complete!")
        }
    }
    
    private func connectAudioGraph(format: AVAudioFormat) {
        
        #warning("Not dettaching nodes from engine!")
        
        guard let effectOne = self.effectOne else { fatalError("effects not setup! call setupEffects first and wait for completion") }
        
        // attach nodes
        engine.attach(self.player)
        engine.attach(effectOne)
        
        // connect nodes
        engine.connect(player, to: effectOne, format: format)
        engine.connect(effectOne, to: engine.mainMixerNode, format: format)
    }
    
    func play() {
        
        player.play(at: nil)
    }
    
    lazy var availableAudioUnitComponents: [AVAudioUnitComponent] = {
        
        let hyperBarnAUDescription = AudioComponentDescription(componentType: kAudioUnitType_Effect, componentSubType: 0, componentManufacturer: 0x68797062, componentFlags: 0, componentFlagsMask: 0)
        return AVAudioUnitComponentManager.shared().components(matching: hyperBarnAUDescription) // slow
    }()
    
}
