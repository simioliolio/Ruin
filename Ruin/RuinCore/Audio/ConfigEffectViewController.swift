//
//  ConfigEffectViewController.swift
//  Ruin
//
//  Created by Simon Haycock on 11/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import UIKit
import AudioUnit
import RuinCore

class ConfigEffectViewController: UIViewController {
    
    @IBOutlet weak var safeContainer: UIView!
    
    private var store = Store.shared
    private var currentAudioUnit: AUAudioUnit?
    private var currentAudioUnitViewController: UIViewController?
    private var uuid = UUID()
    
    var index: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
        store.dispatchAction(RequestEffectsAction())
    }
    
    deinit {
        store.unsubscribe(self)
    }
}

extension ConfigEffectViewController: ReduxStoreSubscriber {
    
    var id: String { uuid.uuidString }
    
    func newState(_ state: State) {
        
        if let loadedEffect = state.loadedEffects[safe: index],
            let auAtIndex = loadedEffect,
            auAtIndex != currentAudioUnit {
            currentAudioUnit = auAtIndex
            DispatchQueue.main.async {
                self.loadViewFor(audioUnit: auAtIndex)
            }
        }
    }
}

extension ConfigEffectViewController {
    
    private func loadViewFor(audioUnit: AUAudioUnit) {
        
        guard let audioUnitName = audioUnit.audioUnitName else {
            fatalError("Unknown audio unit: \(audioUnit)")
        }
        
        var audioUnitViewController: UIViewController?
        
        // TODO: Abstract to existing audio unit factory, declare audioUnit property in protocol conformed to by view controller
        switch audioUnitName {
        case "Stutter":
            let stutterViewController = AudioUnitViewControllerFactory.newStutterViewController
            stutterViewController.audioUnit = audioUnit
            audioUnitViewController = stutterViewController
        default:
            break
        }
        
        guard let uwAudioUnitViewController = audioUnitViewController else {
            fatalError("Could not find a view controller for audio unit with name \(audioUnit.audioUnitName ?? "No name")")
        }
        
        if let uwCurrentAudioUnitViewController = currentAudioUnitViewController {
            remove(uwCurrentAudioUnitViewController)
        }
        add(uwAudioUnitViewController)
        currentAudioUnitViewController = uwAudioUnitViewController
    }
    
    private func remove(_ viewController: UIViewController) {
        if let uwCurrentAudioUnitViewController = currentAudioUnitViewController {
            uwCurrentAudioUnitViewController.removeFromParent()
            uwCurrentAudioUnitViewController.view.removeFromSuperview()
        }
    }
    
    private func add(_ viewController: UIViewController) {
        safeContainer.addSubview(viewController.view)
        addChild(viewController)
    }
}
