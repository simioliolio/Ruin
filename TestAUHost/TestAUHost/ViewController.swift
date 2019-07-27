//
//  ViewController.swift
//  TestAUHost
//
//  Created by Simon Haycock on 08/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    private let engine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()

        let stutter = availableAudioUnitComponents.first { $0.manufacturerName == "hypb" }!
        AVAudioUnit.instantiate(with: stutter.audioComponentDescription, options: [.loadOutOfProcess]) { avAudioUnit, error in
            guard error == nil else {
                fatalError("error making stutter audio unit: \(error)")
            }
            guard let au = avAudioUnit?.audioUnit else {
                fatalError("au is nil")
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    lazy var availableAudioUnitComponents: [AVAudioUnitComponent] = {
        
        let hyperBarnAUDescription = AudioComponentDescription(componentType: kAudioUnitType_Effect,
                                                               componentSubType: 0,
                                                               componentManufacturer: 0,
                                                               componentFlags: 0,
                                                               componentFlagsMask: 0)
        return AVAudioUnitComponentManager.shared().components(matching: hyperBarnAUDescription) // slow
    }()
}

