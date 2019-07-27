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
    
    @IBOutlet weak var enable: NSButton!
    @IBAction func enableChanged(_ sender: Any) {
        enableParameter.value = enableParameter.value > 0 ? 0 : 1
    }
    @IBOutlet weak var length: NSSlider!
    @IBAction func lengthChanged(_ sender: Any) {
        let slider = sender as! NSSlider
        lengthParameter.value = slider.floatValue
    }
    @IBOutlet weak var pitch: NSSlider!
    @IBAction func pitchChanged(_ sender: Any) {
        let slider = sender as! NSSlider
        pitchParameter.value = slider.floatValue
    }
    
    // MARK: AU and AU parameters
    public var audioUnit: AUAudioUnit!
    var enableParameter: AUParameter!
    var lengthParameter: AUParameter!
    var pitchParameter: AUParameter!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let au = audioUnit else {
            return
        }
        connectUI(to: au)
    }
    
    public func connectUI(to au: AUAudioUnit) {
        guard let enableParameterFromTree = au.parameterTree?.allParameters.first(where:{$0.identifier == "enable"})
            else { fatalError("Cannot get enable parameter from AU") }
        enableParameter = enableParameterFromTree
        guard let lengthParameterFromTree = au.parameterTree?.allParameters.first(where:{$0.identifier == "length"})
            else { fatalError("Cannot get length parameter from AU") }
        lengthParameter = lengthParameterFromTree
        guard let pitchParameterFromTree = au.parameterTree?.allParameters.first(where: {$0.identifier == "pitch"})
            else { fatalError("Cannot get pitch parameter from AU") }
        pitchParameter = pitchParameterFromTree
        
        au.parameterTree?.token(byAddingParameterObserver: { [weak self] address, value in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if address == enableParameterFromTree.address {
                    self.enable.title = value == 0 ? "Enable" : "Enabled"
                } else if address == lengthParameterFromTree.address {
                    self.length.floatValue = value
                } else if address == pitchParameterFromTree.address {
                    self.pitch.floatValue = value
                }
            }
        })
    }
    
}
