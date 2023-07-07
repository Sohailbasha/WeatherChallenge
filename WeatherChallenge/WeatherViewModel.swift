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
    
    let locationmanager = CLLocationManager()
    

    func fetchWeatherData(by cityName: String) {
        // turn cityName into coordinates
        // call fetchWatherData
    }
    
    func fetchWeatherData(latitue: Double, longitude: Double) {
        // use weather service to set weather
    }
    
}


extension WeatherViewModel: CLLocationManagerDelegate {
    
}
