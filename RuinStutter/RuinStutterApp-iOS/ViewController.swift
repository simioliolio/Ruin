//
//  ViewController.swift
//  RuinStutter
//
//  Created by Simon Haycock on 06/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import UIKit
import CoreAudioKit
import RuinStutterFramework_iOS

class ViewController: UIViewController {
    
    @IBOutlet weak var audioUnitContainer: UIView!

    let audioEngine = RUAudioEngine()
    
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
        componentDescription.componentManufacturer = 0x68797062 /*'hypb'*/
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
        
        /*
         Register our `AUAudioUnit` subclass, `AUv3FilterDemo`, to make it able
         to be instantiated via its component description.
         
         Note that this registration is local to this process.
         */
        AUAudioUnit.registerSubclass(RuinStutterAudioUnit.self, as: componentDescription, name:"RuinStutterAU-iOS", version: UInt32.max)
        
        audioEngine.setup {
            
            // play a test track
            let url = Bundle.main.url(forResource: "Air - New Star In The Sky", withExtension: "mp3")!
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
        
        let builtInPlugInsURL = Bundle.main.builtInPlugInsURL!
        let pluginURL = builtInPlugInsURL.appendingPathComponent("RuinStutterAU-iOS.appex")
        let appExtensionBundle = Bundle(url: pluginURL)
        
        let storyboard = UIStoryboard(name: "MainInterface", bundle: appExtensionBundle)
        let auViewController = storyboard.instantiateInitialViewController() as! RuinStutterAudioUnitViewController
        auViewController.audioUnit = audioUnit
        DispatchQueue.main.async {
            auViewController.view.frame = self.audioUnitContainer.bounds
            self.audioUnitContainer.addSubview(auViewController.view)
            self.addChild(auViewController)
            auViewController.didMove(toParent: self)
        }
    }
}

