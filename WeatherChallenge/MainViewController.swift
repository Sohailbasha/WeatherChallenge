//
//  MainViewController.swift
//  WeatherChallenge
//
//  Created by Ilias Basha on 7/7/23.
//

import UIKit
import CoreLocation
import Combine

class MainViewController: UIViewController {
    
    // user default for last searched city name
    let kLastSearchedPlace = "lastSearchedPlace"
    
    var locationManager: CLLocationManager?

    var viewModel = WeatherViewModel()
    
    let tableView: UITableView = UITableView()
    
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "weatherCell")
        
        
        
        let userDefaults = UserDefaults.standard
        if let lastSearchedPlace = userDefaults.string(forKey: kLastSearchedPlace) {
            // make a request for that city name
        } else {
            // get current location
            // if we can't use CL, use SF
            // default to san fransisco
        }
        
        viewModel.$placeName
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$weather
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
       
        viewModel.fetchWeatherDataAndReverseGeocode(latitude: 37.7749, longitude: -122.4194)
        tableView.reloadData()
    }
    
    func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
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
    
    enum WeatherSection: Int {
        case currentTemp = 0
        case hourlyTemps = 1
        case dailyTemps = 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // per section, return number of items
        if section == WeatherSection.currentTemp.rawValue {
            return viewModel.weather?.current.weather.count ?? 0
            
        } else if section == WeatherSection.hourlyTemps.rawValue {
            return viewModel.weather?.hourly.count ?? 0
            
        } else if section == WeatherSection.dailyTemps.rawValue {
            return viewModel.weather?.daily.count ?? 0
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
        
        
        if indexPath.section == 0 {
            if let currentWeather = viewModel.weather?.current, let name = viewModel.placeName {
                
//                cell.textLabel?.text = "Temperature: \(currentWeather.temp)"
                cell.textLabel?.text = "\(name) current temp \(currentWeather.temp)"
            }
        }
        
        
        return cell
    }
    
}
