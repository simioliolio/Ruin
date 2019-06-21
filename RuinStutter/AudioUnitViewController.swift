//
//  AudioUnitViewController.swift
//  RuinStutter
//
//  Created by Simon Haycock on 27/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import CoreAudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    @IBOutlet weak var enable: UIButton!
    @IBOutlet weak var length: UISlider!
    var audioUnit: AUAudioUnit?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let au = audioUnit else { return }
        
        guard let enableParameter = au.parameterTree?.allParameters.first(where:{$0.identifier == "enable"})
            else { fatalError("Cannot get enable parameter") }
        
        guard let lengthParameter = au.parameterTree?.allParameters.first(where:{$0.identifier == "length"})
            else { fatalError("Cannot get length parameter") }
        
        au.parameterTree?.token(byAddingParameterObserver: { [weak self] address, value in
            guard let self = self else { return }
            if address == enableParameter.address {
                value == 0 ? self.enable.setTitle("Enable", for: .normal) : self.enable.setTitle("Enabled", for: .normal)
            } else if address == lengthParameter.address {
                self.length.setValue(value, animated: false)
            }
        })
    }
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try RuinStutterAudioUnit(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }
    
}
