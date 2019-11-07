//
//  AudioPlayer.swift
//  RuinCore
//
//  Created by Simon Haycock on 05/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import AVFoundation

final public class AudioPlayer {
    
    let player = AVAudioPlayerNode()
    var audioFile: AVAudioFile?
    
    // TODO: key path to expose player node's property?
    var isPlaying: Bool { player.isPlaying }
    
    init() { }
    
    func load(url: URL) {
        guard let audioFile = try? AVAudioFile(forReading: url) else { return assertionFailure("could not get av audio file") }
        self.audioFile = audioFile
    }
    
    func play() {
        guard let audioFile = audioFile else { return }
        player.scheduleFile(audioFile, at: nil, completionHandler: nil)
        player.play(at: nil)
    }
    
    func stop() {
        player.stop()
    }
}
