//
//  Weather.swift
//  WeatherChallenge
//
//  Created by Ilias Basha on 7/7/23.
//

import Foundation

struct Weather: Decodable {
  let current: Current
  let hourly: [Hourly]
  let daily: [Daily]
}

struct Current: Decodable {
  let temp: Double
  let weather: [WeatherDetail]
}

struct Hourly: Decodable {
  let temp: Double
  let weather: [WeatherDetail]
}

struct Daily: Decodable {
  let temp: Temperature
  let weather: [WeatherDetail]
}

struct Temperature: Decodable {
  let day: Double
}

struct WeatherDetail: Decodable {
  let id: Int
  let description: String
  let icon: String
}
