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
    func player(_ player: AudioPlayer, published newPositionInSeconds: Int)
    func error(in player: AudioPlayer, error: Error?)
}

final public class AudioPlayer {
    
    let player = AVAudioPlayerNode()
    var audioFile: AVAudioFile?
    
    var framePositionWhenLastStopped: AVAudioFramePosition = 0
    lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(self.publishPlayhead))
        displayLink.add(to: .main, forMode: .defaultRunLoopMode)
        displayLink.isPaused = true
        return displayLink
    }()
    let publishQueue = DispatchQueue(label: "Player publish queue", qos: .background)
    var lastPublishedPositionInSeconds: Int?
    
    weak var delegate: AudioPlayerDelegate?
    
    // TODO: key path to expose player node's property?
    var isPlaying: Bool { player.isPlaying }
    
    init() { }
    
    func load(url: URL) {
        guard let audioFile = try? AVAudioFile(forReading: url) else { return assertionFailure("could not get av audio file") }
        self.audioFile = audioFile
        delegate?.player(self, didLoad: audioFile)
        player.scheduleFile(audioFile, at: nil, completionHandler:nil)
        delegate?.playerPaused(self)
    }
    
    func play() {
        player.play(at: nil)
        enablePublishingPlayhead(true)
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
        framePositionWhenLastStopped = startFrame
        if wasPlaying {
            play()
        }
    }
    
    func pause() {
        player.pause()
        enablePublishingPlayhead(false)
        delegate?.playerPaused(self)
    }
    
    func stop() {
        enablePublishingPlayhead(false)
        player.stop()
        // TODO: new method for when player is stopped?
        delegate?.playerPaused(self)
    }
    
    public enum PlayerError: Error {
        case noAudioFileLoaded
    }
}

extension AudioPlayer {
    
    func enablePublishingPlayhead(_ publish: Bool) {
        displayLink.isPaused = publish ? false : true
    }
    
    @objc
    func publishPlayhead() {
        publishQueue.async {
            guard let currentPlayerTime = self.currentPlayerTime else { return }
            let framePosition = currentPlayerTime.sampleTime + self.framePositionWhenLastStopped
            let secondsPosition = Double(framePosition) / currentPlayerTime.sampleRate
            let secondsPositionInt = Int(secondsPosition)
            if secondsPositionInt != self.lastPublishedPositionInSeconds {
                self.delegate?.player(self, published: secondsPositionInt)
                self.lastPublishedPositionInSeconds = secondsPositionInt
            }
        }
    }
    
    private var currentPlayerTime: AVAudioTime? {
        guard let lastRenderTime = self.player.lastRenderTime else {
            return nil
        }
        guard let currentPlayerTime = self.player.playerTime(forNodeTime: lastRenderTime) else {
            return nil
        }
        return currentPlayerTime
    }
}
