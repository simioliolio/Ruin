//
//  AudioPlayer.swift
//  RuinCore
//
//  Created by Simon Haycock on 05/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import AVFoundation

protocol AudioPlayerDelegate: class {
    func playerStarted(_ player: AudioPlayer)
    func playerStopped(_ player: AudioPlayer)
    func error(in player: AudioPlayer, error: Error?)
}

final public class AudioPlayer {
    
    let player = AVAudioPlayerNode()
    var audioFile: AVAudioFile?
    weak var delegate: AudioPlayerDelegate?
    
    // TODO: key path to expose player node's property?
    var isPlaying: Bool { player.isPlaying }
    
    init() { }
    
    func load(url: URL) {
        guard let audioFile = try? AVAudioFile(forReading: url) else { return assertionFailure("could not get av audio file") }
        self.audioFile = audioFile
        delegate?.playerStopped(self)
    }
    
    func play() {
        guard let audioFile = audioFile else {
            delegate?.error(in: self, error: PlayerError.noAudioFileLoaded)
            return
        }
        player.scheduleFile(audioFile, at: nil, completionHandler:nil)
        self.player.play(at: nil)
        self.delegate?.playerStarted(self)
    }
    
    func stop() {
        player.stop()
        delegate?.playerStopped(self)
    }
    
    public enum PlayerError: Error {
        case noAudioFileLoaded
    }
}
