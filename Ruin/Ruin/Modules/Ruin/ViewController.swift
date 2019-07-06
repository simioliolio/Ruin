//
//  ViewController.swift
//  Ruin
//
//  Created by Simon Haycock on 07/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import UIKit
import RuinCore

class ViewController: UIViewController {
    
    @IBOutlet weak var play: UIButton!
    private var store = RUStore.shared.store
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.subscribe(self)
    }
    
    @IBAction func playTapped(_ sender: Any) {
        store.dispatchAction(RUTogglePlaybackAction())
    }
}

extension ViewController: StoreSubscriber {
    
    func newState(_ state: RUState) {
        play.setTitle(state.playing ? "Playing" : "Stopped", for: .normal)
    }
    
}

