//
//  Model.swift

import Foundation

struct CurrentWeather: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let clouds: Clouds
    let name: String
    let dt: Int
    let sys: Sys
    let coord: Coordinates
}

struct Weather: Codable, Identifiable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Int
    let pressure: Int
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let country: String
    let sunrise: Int
    let sunset: Int
}

struct Coordinates: Codable {
    let lon: Double
    let lat: Double
}


struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Codable, Identifiable {
    var id: UUID { UUID() }
    let dt: Int
    let main: Main
    let weather: [Weather]
    let dt_txt: String
}

struct City: Codable {
    let name: String
    let country: String
}

enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
