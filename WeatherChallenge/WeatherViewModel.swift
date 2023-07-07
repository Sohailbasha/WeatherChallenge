//
//  WeatherViewModel.swift
//  WeatherChallenge
//
//  Created by Ilias Basha on 7/7/23.
//

import Foundation
import Combine
import CoreLocation

class WeatherViewModel: NSObject, ObservableObject {

    @Published var weather: Weather?
    @Published var placeName: String?
    
    var cancellables = Set<AnyCancellable>()
    
    private let weatherService = WeatherService.shared
    private var shouldFetchWeather = false
    
    private let locationManager = CLLocationManager()
    
    weak var viewModelLocationDelegate: WeatherViewModelLocationDelegate?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func getCurrentLocation() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        } else if authorizationStatus == .denied || authorizationStatus == .restricted {
            viewModelLocationDelegate?.sendUserToSettings()
            
        }
      }

    func fetchWeatherData(by inputString: String) {
        weatherService.geocodeLocation(textInput: inputString)
            .flatMap { [weak self] geocodeResponse -> AnyPublisher<Weather, Error> in
                guard let self = self else {
                    return Fail(error: WeatherServiceError.unknown).eraseToAnyPublisher()
                }
                let latitude = geocodeResponse.lat
                let longitude = geocodeResponse.lon
                return self.weatherService.fetchWeatherData(latitude: latitude, longitude: longitude)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // Handle the completion, if needed
            }, receiveValue: { [weak self] weather in
                self?.weather = weather
                self?.placeName = inputString
                UserDefaults.standard.set(inputString, forKey: kLastSearchedPlace)
            })
            .store(in: &cancellables)
        
        UserDefaults.standard.synchronize()
    }
    
    func fetchWeatherDataAndReverseGeocode(latitude: Double, longitude: Double) {
        let weatherPublisher = weatherService.fetchWeatherData(latitude: latitude, longitude: longitude)
        let reverseGeocodingPublisher = weatherService.reverseGeocode(latitude: latitude, longitude: longitude)
        
        Publishers.Zip(weatherPublisher, reverseGeocodingPublisher)
          .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
              print("Error: \(error)")
            case .finished:
              break
            }
          }, receiveValue: { [weak self] weather, placeName in
            self?.weather = weather
            self?.placeName = placeName
              print(placeName)
              UserDefaults.standard.set(placeName, forKey: kLastSearchedPlace)
          })
          .store(in: &cancellables)
    }
}

protocol WeatherViewModelLocationDelegate: AnyObject {
    func sendUserToSettings()
}

extension WeatherViewModel: CLLocationManagerDelegate {
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
          switch status {
          case .notDetermined:
              locationManager.requestWhenInUseAuthorization()
          case .authorizedWhenInUse, .authorizedAlways:
              locationManager.startUpdatingLocation()
          case .denied, .restricted:
              fetchWeatherDataAndReverseGeocode(latitude: 37.7749, longitude: -122.4194)
              // alert the user letting them know to give access
          default:
              return
          }
      }
      
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          if let location = locations.first {
              locationManager.stopUpdatingLocation()
              fetchWeatherDataAndReverseGeocode(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
          }
      }
      
      func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
          print(error)
      }
}
