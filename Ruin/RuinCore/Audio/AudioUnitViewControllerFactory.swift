//
//  AudioUnitViewControllerFactory.swift
//  Ruin
//
//  Created by Simon Haycock on 12/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import UIKit
import RuinStutterFramework_iOS

struct AudioUnitViewControllerFactory {
    
    static func viewControllerForAudioUnitWith(name: String) -> UIViewController? {
        
        let stutterName = "Stutter"
        
        switch name {
        case stutterName:
            return newStutterViewController
            
        default:
            assertionFailure("Unrecognised audio unit")
            return nil
        }
    }
    
    static var newStutterViewController: RuinStutterAudioUnitViewController {

        let stutterFrameworkBundle = Bundle(for: RuinStutterAudioUnitViewController.self)
        let storyboard = UIStoryboard(name: "MainInterface", bundle: stutterFrameworkBundle)
        let stutterViewController = storyboard.instantiateInitialViewController() as! RuinStutterAudioUnitViewController
        return stutterViewController
    }
    
}
