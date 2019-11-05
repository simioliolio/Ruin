//
//  AudioPlayer.swift
//  RuinCore
//
//  Created by Simon Haycock on 05/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import AVFoundation

final public class AudioPlayer {
    
    let playerNode = AVAudioPlayerNode()
    
    // TODO: key path to expose player node's property?
    var isPlaying: Bool { playerNode.isPlaying }
    
    init() { }
    
    func load(url: URL) {
        guard let audioFile = try? AVAudioFile(forReading: url) else { return assertionFailure("could not get av audio file") }
        guard let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length)) else { return assertionFailure("Couldn't make audio buffer from audio file \(audioFile)") } // TODO: Throw
        do {
            try audioFile.read(into: audioFileBuffer)
        } catch {
            fatalError("error: \(error)")
        }
        playerNode.scheduleBuffer(audioFileBuffer, at: nil, options: .loops, completionHandler: nil)
    }
    
    func play() {
        playerNode.play(at: nil)
    }
    
    func stop() {
        playerNode.stop()
    }
}
