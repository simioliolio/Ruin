//
//  ViewController.swift
//  Ruin
//
//  Created by Simon Haycock on 07/04/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import UIKit
import RuinCore

class RuinViewController: UIViewController {
    
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var track: UILabel!
    @IBOutlet weak var position: UISlider!
    @IBAction func positionValueChanged(_ sender: UISlider) {
        positionChanged(choosing: true, positionAsPercentage: sender.value)
    }
    @IBAction func positionTouchCancel(_ sender: UISlider) {
        positionChanged(choosing: false, positionAsPercentage: sender.value)
    }
    @IBAction func positionTouchUpInside(_ sender: UISlider) {
        positionChanged(choosing: false, positionAsPercentage: sender.value)
    }
    @IBAction func positionTouchUpOutside(_ sender: UISlider) {
        positionChanged(choosing: false, positionAsPercentage: sender.value)
    }
    @IBOutlet weak var leftXy: XYControl!
    @IBOutlet weak var middleXy: XYControl!
    @IBOutlet weak var rightXy: XYControl!
    @IBOutlet weak var play: UIButton!
    
    private let store = Store.shared
    private let disposeBag = ReduxDisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlayButton()
        
        [leftXy, middleXy, rightXy].enumerated().forEach {
            $1?.tag = $0
            $1?.delegate = self
        }
        
        Observable { $0.isPlaying }
            .subscribe(on: store)
            .onChange(currentState: store.state) { substate in
                DispatchQueue.main.async { self.play.isSelected = substate } }
            .dispose(by: disposeBag)
    }
    
    private func setupPlayButton() {
        play.layer.borderWidth = 1.0
        play.layer.borderColor = UIColor.systemYellow.cgColor
        play.layer.cornerRadius = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
}

extension RuinViewController {
    
    @IBAction func playTapped(_ sender: Any) {
        store.dispatchAction(TogglePlaybackAction())
    }
    
    func positionChanged(choosing: Bool, positionAsPercentage: Float) {
        store.dispatchAction(PositionChangeAction(choosing: choosing, positionAsPercentage: positionAsPercentage))
    }
}

extension RuinViewController: ReduxStoreSubscriber {
    
    var id: String { String(describing: RuinViewController.self) }
    
    func newState(_ state: State) {
        
        DispatchQueue.main.async {
            self.play.isSelected = state.isPlaying
            if state.choosingPosition == false {
                self.position.value = Float(state.currentPlaybackPosition / state.audioFileLength)                
            }
            self.artist.text = state.audioFileArtist
            self.track.text = state.audioFileTitle
        }
    }
    
}

extension RuinViewController: XYControlDelegate {
    func xyControl(_ xyControl: XYControl, didUpdateTo state: XYControl.Status) {
        let action = XyControlAction(index: xyControl.tag, activated: state.activated, position: state.point)
        store.dispatchAction(action)
    }
}

