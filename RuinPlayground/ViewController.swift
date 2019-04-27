//
//  ViewController.swift
//  RuinPlayground
//
//  Created by Simon Haycock on 17/06/2018.
//  Copyright © 2018 Hyper Barn LTD. All rights reserved.
//

import UIKit
import RuinCore

class ViewController: UIViewController {
    
    let audioEngine = RUAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "Air - New Star In The Sky", withExtension: "mp3")!
        do {
            try audioEngine.load(audioFile: url)
            audioEngine.play()
        } catch {
            fatalError("error playing audio file with url \(url). error: \(error)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

