//
//  MainViewController.swift
//  WeatherChallenge
//
//  Created by Ilias Basha on 7/7/23.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    // user default for last searched city name
    let kLastSearchedPlace = "lastSearchedPlace"
    
    var locationManager: CLLocationManager?
    
    let tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults.standard
        if let lastSearchedPlace = userDefaults.string(forKey: kLastSearchedPlace) {
            // make a request for that city name
        } else {
            // use current location if we have one.
            // default to san fransisco
        }
        
        setupViews()
    }
    
    func setupViews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // weather's 3 array properties
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // per section, return number of items
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
        
        return cell
    }
    
}
