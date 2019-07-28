//
//  ViewController.swift
//  RuinAUHost
//
//  Created by Simon Haycock on 28/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import Cocoa
import RuinStutterFramework_macOS

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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ViewController.AudioUnit.allCases.forEach {
            auSelect.addItem(withTitle: $0.rawValue)
        }
        
        let stutterVC = RuinStutterAUViewController(nibName: nil, bundle: Bundle(for: RuinStutterAUViewController.self))
        auContainer.addSubview(stutterVC.view)
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func load(au: ViewController.AudioUnit) {
        
    }

}

