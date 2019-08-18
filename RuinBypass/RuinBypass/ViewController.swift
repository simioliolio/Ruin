//
//  ViewController.swift
//  RuinBypass
//
//  Created by Simon Haycock on 28/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Cocoa
import AudioToolbox
import CoreAudioKit
import RuinBypassFramework_macOS
import RuinAURoadie

class ViewController: NSViewController {
    
    @IBOutlet weak var auContainer: NSView!
    
    let audioEngine = AURAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()

        AUAudioUnit.registerSubclass(RuinBypassAudioUnit.self, as: RuinBypassAudioUnit.componentDescription, name:RuinBypassAudioUnit.componentName, version: UInt32.max)

        audioEngine.setup(desc: RuinBypassAudioUnit.componentDescription) {
            // play a test track
            let url = Bundle.main.url(forResource: "100hz_5s", withExtension: "wav")!
            do {
                try self.audioEngine.load(audioFile: url)
                self.audioEngine.play()
            } catch {
                fatalError("error playing audio file with url \(url). error: \(error)")
            }

            // show view of first effect
            guard let effectOne = self.audioEngine.effectOne else { fatalError("no first effect after setup") }
            self.showAUView(effectOne.auAudioUnit)
        }
        
        
    }
    
    private func showAUView(_ audioUnit: AUAudioUnit) {
        let vc = RuinBypassAUViewController(nibName: nil, bundle: Bundle(for: RuinBypassAUViewController.self))
        vc.audioUnit = audioUnit
        DispatchQueue.main.async {
            vc.view.frame = self.auContainer.bounds
            self.auContainer.addSubview(vc.view)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

