//
//  AudioInterface.swift
//  RuinCore
//
//  Created by Simon Haycock on 05/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation

//*

/**
 Takes simple interactions and translates them into operations on the audio engine
 Also reacts to changes in the audio engine and sends out data useful for the UI
 */
final public class AudioInterface {
    
    private let store = Store.shared.store
    private let uuid = UUID()
    private let audioPlayer: AudioPlayer
    private let audioEngine: AudioEngine
    
    public init() {
        audioPlayer = AudioPlayer()
        audioEngine = AudioEngine(player: audioPlayer)
        audioEngine.delegate = self
        audioPlayer.delegate = self
        store.subscribe(self)
        try? audioEngine.setup()
    }
    
    deinit {
        store.unsubscribe(self)
    }
}

extension AudioInterface: ReduxMiddleware {
    
    public typealias SubscribedState = State
    public var id: String { uuid.uuidString }
    
    public func action(_ action: ReduxAction, state: State?) {
        
        guard let state = state else { return }
        switch action {
        case is TogglePlaybackAction:
            apply(playbackStatus: !state.isPlaying)
        case let action as XyControlAction:
            apply(xyControlState: (action.index, action.activated, action.position))
        case let action as PositionChangeAction:
            if action.choosing == false {
                // TODO: Should view know more about audio file length, and handle
                // converting from % to time?
                let newPosition = TimeInterval(action.positionAsPercentage) * state.audioFileLength
                apply(newPosition: newPosition)
            }
        default:
            break
        }
    }
}

// MARK: Apply changes to audio engine / player
extension AudioInterface {
    
    private func apply(playbackStatus: Bool) {
        playbackStatus ? audioPlayer.play() : audioPlayer.pause()
    }
    
    private func apply(xyControlState: (index: Int, activated: Bool, position: CGPoint)) {
        // TODO: Forward xy control changes to effect interface which
        // controls the audio unit's parameters
        
    }
    
    private func apply(newPosition: TimeInterval) {
        // TODO: go to new position using audioPlayer
    }
    
}
 
extension AudioInterface: AudioEngineDelegate {
    
    func didStartAudioEngine() {
        // TODO: Issue action
        // temp
        let url = Bundle.main.url(forResource: "Air - New Star In The Sky", withExtension: "mp3")!
        audioPlayer.load(url: url)
    }
    
    func didFailToStartAudioEngine() {
        // TODO: Handle didFailToStartAudioEngine
    }
}

extension AudioInterface: AudioPlayerDelegate {
    
    func playerStarted(_ player: AudioPlayer) {
        store.dispatchAction(AudioPlayerPlaybackStatusAction(playing: true))
    }
    
    func playerPaused(_ player: AudioPlayer) {
        store.dispatchAction(AudioPlayerPlaybackStatusAction(playing: false))
    }
    
    func error(in player: AudioPlayer, error: Error?) {
        // TODO: Dispatch error action
    }
}

extension AudioInterface: Equatable {
    
    public static func == (lhs: AudioInterface, rhs: AudioInterface) -> Bool {
        lhs.uuid == rhs.uuid
    }
}
