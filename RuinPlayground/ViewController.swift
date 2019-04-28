//
//  ViewController.swift
//  RuinPlayground
//
//  Created by Simon Haycock on 17/06/2018.
//  Copyright © 2018 Hyper Barn LTD. All rights reserved.
//

import UIKit
@testable import RuinCore

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let audioEngine = RUAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioEngine.setupEffects {
            
            // play a test track
            let url = Bundle.main.url(forResource: "Air - New Star In The Sky", withExtension: "mp3")!
            do {
                try self.audioEngine.load(audioFile: url)
                self.audioEngine.play()
            } catch {
                fatalError("error playing audio file with url \(url). error: \(error)")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return audioEngine.availableAudioUnitComponents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell")!
        cell.textLabel?.text = audioEngine.availableAudioUnitComponents[indexPath.row].name
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}
