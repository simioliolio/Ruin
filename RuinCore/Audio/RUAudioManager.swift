//
//  RUAudioManager.swift
//  RuinCore
//
//  Created by Simon Haycock on 14/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AVFoundation

public final class RUAudioManager {
    
    let engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    
    public init() { }
    
    public func play(audioFile url: URL) throws {
        
        let audioFile = try AVAudioFile(forReading: url)
        if player.engine != nil {
            player.stop()
            engine.disconnectNodeOutput(player)
        } else {
            engine.attach(player)
        }
        
        engine.connect(player, to: engine.mainMixerNode, format: audioFile.processingFormat)
        
        if !engine.isRunning {
            try engine.start()
        }
        
        player.play(at: nil)
        player.scheduleFile(audioFile, at: nil) {
            print("complete!")
        }
    }
}
