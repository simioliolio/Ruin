//
//  AudioUnitViewController.swift
//  RuinStutterAU-macOS
//
//  Created by Simon Haycock on 06/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import CoreAudioKit
import RuinStutterFramework_macOS

public class RuinStutterAUViewController: AUViewController {
    public var audioUnit: AUAudioUnit?
    
    @IBOutlet weak var enable: NSButton!
    @IBAction func enableChanged(_ sender: Any) {
        
    }
    @IBOutlet weak var length: NSSliderCell!
    @IBAction func lengthChanged(_ sender: Any) {
        
    }
    @IBOutlet weak var pitch: NSSliderCell!
    @IBAction func pitchChanged(_ sender: Any) {
    }
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let au = audioUnit else {
            return
        }
        
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }
    
    
    
}
