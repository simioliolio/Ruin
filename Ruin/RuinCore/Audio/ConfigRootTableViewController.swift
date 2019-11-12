//
//  ConfigRootTableViewController.swift
//  Ruin
//
//  Created by Simon Haycock on 11/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import UIKit
import AudioUnit
import RuinCore

class ConfigRootTableViewController: UITableViewController, ReduxStoreSubscriber {
    
    private var store = Store.shared
    
    var sectionNames = ["Effects"]
    var effectNames = ["Effect 1", "Effect 2", "Effect 3"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigRootCell", for: indexPath)

        cell.textLabel?.text = effectNames[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let effectVC = segue.destination as? ConfigEffectViewController else { return }
        effectVC.index = tableView.indexPathForSelectedRow?.row
    }
    
    // MARK: ReduxStoreSubscriber
    
    var id: String { String(describing: ConfigRootTableViewController.self) }
    
    func newState(_ state: State) {
        // TODO: Update effect names and colours on main thread!
    }
}
