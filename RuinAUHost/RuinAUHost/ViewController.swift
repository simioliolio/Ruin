//
//  ViewController.swift
//  RuinAUHost
//
//  Created by Simon Haycock on 28/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Cocoa
import RuinBypassFramework_macOS
import RuinStutterFramework_macOS
import RuinAURoadie

class ViewController: NSViewController {
    
    enum AudioUnit: String, CaseIterable {
        case bypass
        case stutter
    }
    
    @IBOutlet weak var auSelect: NSPopUpButton!
    @IBAction func auSelected(_ sender: Any) {
        let popUp = sender as! NSPopUpButton
        guard let auName = popUp.titleOfSelectedItem, let au = ViewController.AudioUnit(rawValue: auName) else {
            fatalError("either no selected item, or selected item is not a known audio unit")
        }
        load(au: au) { }
    }
    
    @IBOutlet weak var effectOn: NSButton!
    @IBOutlet weak var xSlider: NSSlider!
    @IBOutlet weak var ySlider: NSSlider!
    @IBOutlet weak var learnX: NSButton!
    @IBOutlet weak var learnY: NSButton!
    @IBOutlet weak var auContainer: NSView!
    
    var currentVC: NSViewController?
    
    let audioEngine = AURAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ViewController.AudioUnit.allCases.forEach {
            auSelect.addItem(withTitle: $0.rawValue)
        }
        
        AUAudioUnit.registerSubclass(RuinBypassAudioUnit.self, as: RuinBypassAudioUnit.componentDescription, name:RuinBypassAudioUnit.componentName, version: UInt32.max)
        load(au: .bypass) {
            // play a test track
            let url = Bundle.main.url(forResource: "Air - New Star In The Sky", withExtension: "mp3")!
            do {
                try self.audioEngine.load(audioFile: url)
                self.audioEngine.play()
            } catch {
                fatalError("error playing audio file with url \(url). error: \(error)")
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func load(au: ViewController.AudioUnit, completion: @escaping ()->()) {
        let info = infoForAudioUnit(au)
        AUAudioUnit.registerSubclass(info.audioUnitClass, as: info.componentDescription, name: info.componentName, version: UInt32.max)
        
        audioEngine.setup(desc: info.componentDescription) { audioUnit in
            if let uwCurrentVC = self.currentVC {
                uwCurrentVC.removeFromParent()
                uwCurrentVC.view.removeFromSuperview()
            }
            var audioUnitVC = self.viewControllerForAudioUnit(au)
            audioUnitVC.audioUnit = audioUnit?.auAudioUnit
            self.auContainer.addSubview(audioUnitVC.view)
            self.addChild(audioUnitVC)
            completion()
        }
        
    }
    
    struct AudioUnitInfo {
        let audioUnitClass: AnyClass
        let componentDescription: AudioComponentDescription
        let componentName: String
    }

    private func infoForAudioUnit(_ audioUnit: ViewController.AudioUnit) -> AudioUnitInfo {
        switch audioUnit {
        case .bypass:
            return AudioUnitInfo(audioUnitClass: RuinBypassAudioUnit.self,
                                 componentDescription: RuinBypassAudioUnit.componentDescription,
                                 componentName: RuinBypassAudioUnit.componentName)
        case .stutter:
            return AudioUnitInfo(audioUnitClass: RuinStutterAudioUnit.self,
                                 componentDescription: RuinStutterAudioUnit.componentDescription,
                                 componentName: RuinStutterAudioUnit.componentName)
        }
    }
    
    private func viewControllerForAudioUnit(_ audioUnit: ViewController.AudioUnit) -> (NSViewController & AURAudioUnitViewController) {
        switch audioUnit {
        case .bypass:
            return RuinBypassAUViewController(nibName: nil, bundle: Bundle(for: RuinBypassAUViewController.self))
        case .stutter:
            return RuinStutterAUViewController(nibName: nil, bundle: Bundle(for: RuinStutterAUViewController.self))
        }
    }
}
