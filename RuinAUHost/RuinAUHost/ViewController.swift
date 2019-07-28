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
        case noAudioUnit
        case Stutter
    }
    
    @IBOutlet weak var auSelect: NSPopUpButton!
    @IBAction func auSelected(_ sender: Any) {
        let popUp = sender as! NSPopUpButton
        guard let auName = popUp.titleOfSelectedItem, let au = ViewController.AudioUnit(rawValue: auName) else {
            fatalError("either no selected item, or selected item is not a known audio unit")
        }
        load(au: au)
    }
    
    @IBOutlet weak var effectOn: NSButton!
    @IBOutlet weak var xSlider: NSSlider!
    @IBOutlet weak var ySlider: NSSlider!
    @IBOutlet weak var learnX: NSButton!
    @IBOutlet weak var learnY: NSButton!
    @IBOutlet weak var auContainer: NSView!
    
    let audioEngine = AURAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ViewController.AudioUnit.allCases.forEach {
            auSelect.addItem(withTitle: $0.rawValue)
        }
        
        AUAudioUnit.registerSubclass(RuinBypassAudioUnit.self, as: RuinBypassAudioUnit.componentDescription, name:RuinBypassAudioUnit.componentName, version: UInt32.max)
        
        audioEngine.setup(desc: RuinBypassAudioUnit.componentDescription) {
            // play a test track
            let url = Bundle.main.url(forResource: "Air - New Star In The Sky", withExtension: "mp3")!
            do {
                try self.audioEngine.load(audioFile: url)
                self.audioEngine.play()
            } catch {
                fatalError("error playing audio file with url \(url). error: \(error)")
            }
            
            let bypassVC = RuinBypassAUViewController(nibName: nil, bundle: Bundle(for: RuinBypassAUViewController.self))
            bypassVC.view.frame = self.view.bounds
            self.auContainer.addSubview(bypassVC.view)
            self.addChild(bypassVC)
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func load(au: ViewController.AudioUnit) {
        
    }

}

