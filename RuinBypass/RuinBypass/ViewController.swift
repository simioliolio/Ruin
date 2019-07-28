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

        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_Effect
        componentDescription.componentSubType = 0x64697374 /*'dist'*/
        componentDescription.componentManufacturer = 0x48797062 /*'Hypb'*/
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
        
        AUAudioUnit.registerSubclass(RuinBypassAU_macOSAudioUnit.self, as: componentDescription, name:"Hypb: RuinBypassAU-macOS", version: UInt32.max)

        audioEngine.setup(desc: componentDescription) {
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
        let pluginsURL = Bundle.main.builtInPlugInsURL
        let auExtensionURL = pluginsURL?.appendingPathComponent("RuinBypassAU-macOS.appex")
        let auExtensionBundle = Bundle(url: auExtensionURL!)!
        let vc = RuinBypassAUViewController(nibName: nil, bundle: auExtensionBundle)
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

