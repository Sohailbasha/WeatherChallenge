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

    var viewModel = WeatherViewModel()
    
    let tableView: UITableView = UITableView()
    
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "weatherCell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))

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
    
    @objc func searchButtonTapped() {
        // Handle the search button tap event here
        let searchVC = SearchInputViewController()
//        searchVC.modalPresentationStyle = .overFullScreen
        searchVC.delegate = self
        searchVC.modalPresentationStyle = .overCurrentContext
        self.present(searchVC, animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case WeatherSection.currentTemp.rawValue:
            return "Today's Average Temperature"
        case WeatherSection.hourlyTemps.rawValue:
            return "Hourly Average Temperature"
        case WeatherSection.dailyTemps.rawValue:
            return "Daily Average Temperature"
        default:
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
        
        
        if indexPath.section == 0 {
            if let currentWeather = viewModel.weather?.current, let name = viewModel.placeName {
                cell.textLabel?.text = "\(name) | \(currentWeather.temp)°"
            }
        } else if indexPath.section == WeatherSection.hourlyTemps.rawValue {
            if let hourlyWeather = viewModel.weather?.hourly[indexPath.row] {
                let date = Date(timeIntervalSince1970: Double(hourlyWeather.dt))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h a" // "03 PM"
                let dateString = dateFormatter.string(from: date)
                cell.textLabel?.text = "\(dateString) | \(hourlyWeather.temp)°"
            }
        } else if indexPath.section == WeatherSection.dailyTemps.rawValue {
            if let dailyWeather = viewModel.weather?.daily[indexPath.row] {
                let date = Date(timeIntervalSince1970: Double(dailyWeather.dt))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, MMM d" // "Monday, Jan 1"
                let dateString = dateFormatter.string(from: date)
                cell.textLabel?.text = "\(dateString) | \(dailyWeather.temp.day)°"
            }
        }
        
        return cell
    }
}

extension MainViewController: SearchInputViewControllerDelegate {
    
    func searchViewController(_ viewController: SearchInputViewController, didEnterLocation input: String) {
        print("Did enter location: \(input)")
    }
    
    func searchViewControllerDidTriggerCurrentLocation(_ viewController: SearchInputViewController) {
        print("did trigger CL")
    }
}
