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
    
    private var store = Store.shared.store
    private var currentAudioUnit: AUAudioUnit?
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
            loadViewFor(audioUnit: auAtIndex)
        }
    }
}

extension ConfigEffectViewController {
    
    func loadViewFor(audioUnit: AUAudioUnit) {
        
    }
}
