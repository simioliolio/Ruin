//
//  RuinStutterAudioUnitViewController.swift
//  RuinStutterAU-iOS
//
//  Created by Simon Haycock on 06/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import CoreAudioKit

public class RuinStutterAudioUnitViewController: AUViewController {
    
    // MARK: IB properties / actions
    @IBOutlet weak var enable: UIButton!
    @IBAction func enableToggle(_ sender: Any) {
        enableParameter.value = enableParameter.value > 0 ? 0 : 1
    }
    @IBOutlet weak var length: UISlider!
    @IBAction func lengthChange(_ sender: Any) {
        let slider = sender as! UISlider
        lengthParameter.value = slider.value
    }
    
    @IBOutlet weak var pitch: UISlider!
    @IBAction func pitchChanged(_ sender: Any) {
        let slider = sender as! UISlider
        pitchParameter.value = slider.value
    }
    
    // MARK: AU and AU parameters
    public var audioUnit: AUAudioUnit!
    var enableParameter: AUParameter!
    var lengthParameter: AUParameter!
    var pitchParameter: AUParameter!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let au = audioUnit else { return }
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
                    value == 0 ? self.enable.setTitle("Enable", for: .normal) : self.enable.setTitle("Enabled", for: .normal)
                } else if address == lengthParameterFromTree.address {
                    self.length.setValue(value, animated: false)
                } else if address == pitchParameterFromTree.address {
                    self.pitch.setValue(value, animated: false)
                }
            }
        })
    }
}
