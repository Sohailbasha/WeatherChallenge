//
//  MainViewController.swift
//  WeatherChallenge
//
//  Created by Ilias Basha on 7/7/23.
//

import UIKit
import CoreLocation
import Combine
import SDWebImage

// user default for last searched city name
let kLastSearchedPlace = "lastSearchedPlace"

class MainViewController: UIViewController {
    
    var viewModel = WeatherViewModel()
    
    let tableView: UITableView = UITableView()
    
    var cancellables = Set<AnyCancellable>()
    
    // Had I more time I would have added a loading spinner
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sohail's weather app"
        setupViews()
        
        viewModel.viewModelLocationDelegate = self
        
        let userDefaults = UserDefaults.standard
        if let lastSearchedPlace = userDefaults.string(forKey: kLastSearchedPlace) {
            // make a request for that city name
            viewModel.fetchWeatherData(by: lastSearchedPlace)
        } else {
            // Fall back on users locatoin
            // We don't need to do anything here. Creating the location manager will ask the user for their location. And if they deny, we will set default coordinates
        }
        
        // set up subscriptions to place name and weather properties
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
        
        tableView.reloadData()
    }
    
    @objc func searchButtonTapped() {
        // Handle the search button tap event here
        let searchVC = SearchInputViewController()
        searchVC.delegate = self
        searchVC.modalPresentationStyle = .overCurrentContext
        self.present(searchVC, animated: true, completion: nil)
    }
    
    func setupViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "weatherCell")
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

// Had I had more time I would have utilized CollectionView's
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
        switch section {
        case WeatherSection.currentTemp.rawValue:
            return viewModel.weather?.current.weather.count ?? 0
        case WeatherSection.hourlyTemps.rawValue:
            return viewModel.weather?.hourly.count ?? 0
        case WeatherSection.dailyTemps.rawValue:
            return viewModel.weather?.daily.count ?? 0
        default:
            return 0
        }
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "weatherCell")
        
        switch indexPath.section {
        case WeatherSection.currentTemp.rawValue:
            configureCellForCurrentWeather(cell)
        case WeatherSection.hourlyTemps.rawValue:
            if let hourly = viewModel.weather?.hourly[indexPath.row] {
                configureCellForHourlyWeather(cell, hourly)
            }
        case WeatherSection.dailyTemps.rawValue:
            if let dailyWeather = viewModel.weather?.daily[indexPath.row] {
                configureCellForDailyWeather(cell, dailyWeather)
            }
        default:
            break
        }
        return cell
    }
    
    fileprivate func createWeatherIconImageView(_ iconName: String) -> UIImageView {
        let iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let iconURLString = "https://openweathermap.org/img/w/\(iconName).png"
        if let iconURL = URL(string: iconURLString) {
            iconImageView.sd_setImage(with: iconURL)
        }
        return iconImageView
    }
    
    fileprivate func configureCellForCurrentWeather(_ cell: UITableViewCell) {
        if let currentWeather = viewModel.weather?.current, let name = viewModel.placeName {
            cell.textLabel?.text = "\(name) | \(Int(currentWeather.temp))°"
            cell.detailTextLabel?.text = currentWeather.weather.first?.description
            
            if let icon = currentWeather.weather.first?.icon {
                cell.accessoryView = createWeatherIconImageView(icon)
            } else {
                cell.accessoryView = nil
            }
        }
    }
    
    fileprivate func configureCellForHourlyWeather(_ cell: UITableViewCell, _ hourlyWeather: Hourly) {
        let date = Date(timeIntervalSince1970: Double(hourlyWeather.dt))
        let dateString = viewModel.formattedDateString(from: date, dateFormat: "h a") // "3 PM"
        cell.textLabel?.text = "\(dateString) | \(Int(hourlyWeather.temp))°"
        
        if let icon = hourlyWeather.weather.first?.icon {
            cell.accessoryView = createWeatherIconImageView(icon)
        } else {
            cell.accessoryView = nil
        }
    }
    
    fileprivate func configureCellForDailyWeather(_ cell: UITableViewCell, _ dailyWeather: Daily) {
        let date = Date(timeIntervalSince1970: Double(dailyWeather.dt))
        let dateString = viewModel.formattedDateString(from: date, dateFormat: "EEEE, MMM d") // "Monday, Jan 1"
        cell.textLabel?.text = "\(dateString) | \(Int(dailyWeather.temp.day))°"
        
        if let icon = dailyWeather.weather.first?.icon {
            cell.accessoryView = createWeatherIconImageView(icon)
        } else {
            cell.accessoryView = nil
        }
    }
}

extension MainViewController: SearchInputViewControllerDelegate {
    func searchViewControllerDidEnterLocation(input: String) {
        viewModel.fetchWeatherData(by: input)
    }
    
    func searchViewControllerDidTriggerCurrentLocation() {
        viewModel.getCurrentLocation()
    }
}

extension MainViewController: WeatherViewModelLocationDelegate {
    func sendUserToSettings() {
        let alertController = UIAlertController(
            title: "Location Access Denied",
            message: "Please enable location services in Settings to use the current location feature.",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
