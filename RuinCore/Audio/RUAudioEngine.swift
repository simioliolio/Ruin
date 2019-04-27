//
//  RUAudioEngine.swift
//  RuinCore
//
//  Created by Simon Haycock on 27/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AVFoundation

final public class RUAudioEngine {
    
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    
    public init() {
        
        // attach nodes
        engine.attach(player)
        
        // connect nodes
        engine.connect(player, to: engine.mainMixerNode, format: nil)
    }
    
    public func load(audioFile url: URL) throws {
        
        let audioFile = try AVAudioFile(forReading: url)
        
        if player.isPlaying { player.stop() }
        engine.disconnectNodeOutput(player)
        engine.connect(player, to: engine.mainMixerNode, format: audioFile.processingFormat)
        
        if !engine.isRunning { try engine.start() }
        
        player.scheduleFile(audioFile, at: nil) {
            print("complete!")
        }
    }
    
    public func play() {
        
        player.play(at: nil)
    }
}
