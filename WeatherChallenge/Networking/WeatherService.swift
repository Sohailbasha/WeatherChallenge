//
//  WeatherService.swift
//  WeatherChallenge
//
//  Created by Ilias Basha on 7/7/23.
//

import Foundation
import Combine

class WeatherService {
    static let shared = WeatherService()
    
    private let apiKey = "0cc634344494013af02481e4883eb275"
    private let baseURL = URL(string: "https://api.openweathermap.org/data/3.0/onecall")!
    
    var cancellables = Set<AnyCancellable>()
    
    
    func fetchWeatherData(latitude: Double, longitude: Double) -> AnyPublisher<Weather, Error> {
      var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
      urlComponents.queryItems = [
        URLQueryItem(name: "lat", value: String(latitude)),
        URLQueryItem(name: "lon", value: String(longitude)),
        URLQueryItem(name: "appid", value: apiKey),
        URLQueryItem(name: "units", value: "imperial")
      ]

      let request = URLRequest(url: urlComponents.url!)

      return URLSession.shared.dataTaskPublisher(for: request)
        .map(\.data)
        .decode(type: Weather.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

class ImageService {
    static let shared = ImageService()
}
