//
//  WeatherViewModel.swift
//  WeatherChallenge
//
//  Created by Ilias Basha on 7/7/23.
//

import Foundation
import Combine
import CoreLocation

class WeatherViewModel: NSObject {

    @Published var weather: Weather?
    @Published var placeName: String?
    
    var cancellables = Set<AnyCancellable>()
    
    let locationmanager = CLLocationManager()

    func fetchWeatherData(by cityName: String) {
        // turn cityName into coordinates
        // call fetchWatherData
    }
    
    func fetchWeatherDataAndReverseGeocode(latitude: Double, longitude: Double) {
        let weatherPublisher = WeatherService.shared.fetchWeatherData(latitude: latitude, longitude: longitude)
        let reverseGeocodingPublisher = WeatherService.shared.reverseGeocode(latitude: latitude, longitude: longitude)
        
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
          })
          .store(in: &cancellables)
    }
}


extension WeatherViewModel: CLLocationManagerDelegate {
    
}
