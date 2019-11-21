//
//  AudioPlayerFileLoadAction.swift
//  RuinCore
//
//  Created by Simon Haycock on 10/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Foundation
import AVFoundation

public struct AudioPlayerFileLoadAction: ReduxAction {
    
    public let processingFormat: AVAudioFormat
    public let length: AVAudioFramePosition
    public let artist: String?
    public let title: String?
    
    public init(processingFormat: AVAudioFormat, length: AVAudioFramePosition, artist: String?, title: String?) {
        self.processingFormat = processingFormat
        self.length = length
        self.artist = artist
        self.title = title
    }
}
