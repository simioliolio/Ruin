//
//  AudioPlayer.swift
//  RuinCore
//
//  Created by Simon Haycock on 05/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import AVFoundation

protocol AudioPlayerDelegate: class {
    func player(_ player: AudioPlayer, didLoad audioFile: AVAudioFile)
    func playerStarted(_ player: AudioPlayer)
    func playerPaused(_ player: AudioPlayer)
    func error(in player: AudioPlayer, error: Error?)
}

protocol AudioPlayerFormatDelegate: class {
    func player(_ player: AudioPlayer, didUpdate format: AVAudioFormat)
}

final public class AudioPlayer {
    
    let player = AVAudioPlayerNode()
    var audioFile: AVAudioFile?
    weak var delegate: AudioPlayerDelegate?
    weak var formatDelegate: AudioPlayerFormatDelegate?
    
    // TODO: key path to expose player node's property?
    var isPlaying: Bool { player.isPlaying }
    
    init() { }
    
    func load(url: URL) {
        guard let audioFile = try? AVAudioFile(forReading: url) else { return assertionFailure("could not get av audio file") }
        self.audioFile = audioFile
        formatDelegate?.player(self, didUpdate: audioFile.processingFormat) // inform of change in format before scheduling file
        delegate?.player(self, didLoad: audioFile) // TODO: Single delegate which issues action
        player.scheduleFile(audioFile, at: nil, completionHandler:nil)
        delegate?.playerPaused(self)
    }
    
    func play() {
        player.play(at: nil)
        delegate?.playerStarted(self)
    }
    
    func play(at startFrame: AVAudioFramePosition) {
        let wasPlaying = isPlaying
        stop()
        guard let audioFile = audioFile else {
            delegate?.error(in: self, error: PlayerError.noAudioFileLoaded)
            return
        }
        player.scheduleSegment(audioFile, startingFrame: startFrame, frameCount: AVAudioFrameCount(audioFile.length - startFrame), at: nil, completionHandler: nil)
        if wasPlaying {
            play()
        }
    }
    
    func pause() {
        player.pause()
        delegate?.playerPaused(self)
    }
    
    func stop() {
        player.stop()
        // TODO: new method for when player is stopped?
        delegate?.playerPaused(self)
    }
    
    public enum PlayerError: Error {
        case noAudioFileLoaded
    }
}
