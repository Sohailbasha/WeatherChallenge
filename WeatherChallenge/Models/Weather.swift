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

// model object for current temperature
struct Current: Decodable {
  let temp: Double
  let weather: [WeatherDetail]
}

struct Hourly: Decodable {
    let dt: Int
    let temp: Double
    let weather: [WeatherDetail]
}

struct Daily: Decodable {
    let dt: Int
  let temp: Temperature
  let weather: [WeatherDetail]
}

struct Temperature: Decodable {
  let day: Double
}

// model object to access icons
struct WeatherDetail: Decodable {
  let id: Int
  let description: String
  let icon: String
}

struct Geocoding: Decodable {
  let lat: Double
  let lon: Double
  let name: String
}
