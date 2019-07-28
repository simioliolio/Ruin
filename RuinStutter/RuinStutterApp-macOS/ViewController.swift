//
//  ViewController.swift
//  RuinStutterApp-macOS
//
//  Created by Simon Haycock on 06/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Cocoa
import RuinStutterFramework_macOS
import RuinAURoadie

class ViewController: NSViewController {
    
    @IBOutlet weak var audioUnitContainer: NSView!
    
    let audioEngine = AURAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()

        /*
         Register the AU in-process for development/debugging.
         First, build an AudioComponentDescription matching the one in our
         .appex's Info.plist.
         */
        // MARK: AudioComponentDescription Important!
        // Ensure that you update the AudioComponentDescription for your AudioUnit type, manufacturer and creator type.
        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_Effect
        componentDescription.componentSubType = 0x64697374 /*'dist'*/
        componentDescription.componentManufacturer = 0x48797062 /*'Hypb'*/
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
        
        /*
         Register our `AUAudioUnit` subclass, `AUv3FilterDemo`, to make it able
         to be instantiated via its component description.
         
         Note that this registration is local to this process.
         */
        AUAudioUnit.registerSubclass(RuinStutterAudioUnit.self, as: componentDescription, name:"hypb: RuinStutterAU-macOS", version: UInt32.max)
        
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
        
        let auViewController = RuinStutterAUViewController(nibName: "RuinStutterAUViewController", bundle: Bundle(for: RuinStutterAUViewController.self))
        
        auViewController.audioUnit = audioUnit
        DispatchQueue.main.async {
            auViewController.view.frame = self.audioUnitContainer.bounds
            self.audioUnitContainer.addSubview(auViewController.view)
            self.addChild(auViewController)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

