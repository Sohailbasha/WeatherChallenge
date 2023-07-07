//
//  WeatherService.swift
//  WeatherChallenge
//
//  Created by Ilias Basha on 7/7/23.
//

import Foundation
import Combine

enum WeatherServiceError: Error {
    case invalidURL
    case invalidData
    case noResults
    case unknown
}

class WeatherService {
    static let shared = WeatherService()
    
    private let apiKey = "0cc634344494013af02481e4883eb275"
    private let baseURL = URL(string: "https://api.openweathermap.org/data/3.0/onecall")!
    
    var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
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
    
    func reverseGeocode(latitude: Double, longitude: Double) -> AnyPublisher<String, Error> {
        let geocodingBaseURL = URL(string: "http://api.openweathermap.org/geo/1.0/reverse")!
        
        var urlComponents = URLComponents(url: geocodingBaseURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        let request = URLRequest(url: urlComponents.url!)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Geocoding].self, decoder: JSONDecoder()) // The API returns an array
            .tryMap { geocodingArray in
                guard let geocoding = geocodingArray.first else {
                    throw URLError(.badServerResponse)
                }
                return geocoding.name
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func geocodeLocation(textInput: String) -> AnyPublisher<GeocodeResponse, Error> {
        let endpoint = "https://api.openweathermap.org/geo/1.0/direct"
        
        guard var urlComponents = URLComponents(string: endpoint) else {
            return Fail(error: WeatherServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        let queryItems = [
            URLQueryItem(name: "q", value: textInput),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Fail(error: WeatherServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [GeocodeResponse].self, decoder: JSONDecoder())
            .tryMap { results -> GeocodeResponse in
                guard let firstResult = results.first else {
                    throw WeatherServiceError.noResults
                }
                return firstResult
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
