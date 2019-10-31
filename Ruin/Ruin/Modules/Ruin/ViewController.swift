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
    private var store = Store.shared.store
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.subscribe(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // TODO: Unsubscribe
    }
    
    @IBAction func playTapped(_ sender: Any) {
        store.dispatchAction(TogglePlaybackAction())
    }
}

extension ViewController: ReduxStoreSubscriber {
    
    func newState(_ state: State) {
        play.setTitle(state.playing ? "Playing" : "Stopped", for: .normal)
    }
    
}

