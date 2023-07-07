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
    
    
    
}

class ImageService {
    static let shared = ImageService()
}
