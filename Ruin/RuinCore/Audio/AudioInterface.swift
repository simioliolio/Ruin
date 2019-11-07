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
        store.subscribe(self)
        try? audioEngine.setup()
    }
    
    deinit {
        store.unsubscribe(self)
    }
}

// MARK: Reacting to interactions
extension AudioInterface {
    
    private func apply(playbackStatus: Bool) {
        if playbackStatus == true {
            audioPlayer.play()
        } else {
            audioPlayer.stop()
        }
    }
    
    private func apply(position: TimeInterval) {
        // TODO: Implement
    }
    
}

// MARK: Reacting to changes in the audio engine
// TODO: Make AudioEngine a middleware?
extension AudioInterface: AudioEngineDelegate {
    
    func didStartAudioEngine() {
        let url = Bundle.main.url(forResource: "Air - New Star In The Sky", withExtension: "mp3")!
        audioPlayer.load(url: url)
    }
    
    func didFailToStartAudioEngine() {
        //
    }
    
}

extension AudioInterface: ReduxStoreSubscriber {
    
    public typealias SubscribedState = State
    public var id: String { uuid.uuidString }
    
    public func newState(_ state: State) {
        
        // Playback
        if state.playInteraction != audioPlayer.isPlaying {
            apply(playbackStatus: state.playInteraction)
        }
        
        // Position
        // TODO: Different type of state for this?
        if state.positionInteraction.previouslyEnabled == true && state.positionInteraction.enabled == false {
            // Apply new position
            apply(position: TimeInterval(state.positionInteraction.position) * state.audioFileLength)
        }
        
        // XY interaction
        // TODO: Implement
    }
}

extension AudioInterface: Equatable {
    
    public static func == (lhs: AudioInterface, rhs: AudioInterface) -> Bool {
        lhs.uuid == rhs.uuid
    }
}
