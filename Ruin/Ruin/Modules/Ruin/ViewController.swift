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
    
    @IBOutlet weak var leftXyControl: XYControl!
    @IBOutlet weak var middleXyControl: XYControl!
    @IBOutlet weak var rightXyControl: XYControl!
    @IBOutlet weak var play: UIButton!
    private var store = Store.shared.store
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [leftXyControl, middleXyControl, rightXyControl].enumerated().forEach {
            $1?.tag = $0
            $1?.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    @IBAction func playTapped(_ sender: Any) {
        store.dispatchAction(TogglePlaybackAction())
    }
}

extension ViewController: ReduxStoreSubscriber {
    
    var id: String { String(describing: ViewController.self) }
    
    func newState(_ state: State) {
        
        DispatchQueue.main.async {
            self.play.isSelected = state.isPlaying
        }
    }
    
}

extension ViewController: XYControlDelegate {
    func xyControl(_ xyControl: XYControl, didUpdateTo state: XYControl.Status) {
        let action = XyControlAction(index: xyControl.tag, activated: state.activated, position: state.point)
        store.dispatchAction(action)
    }
}

