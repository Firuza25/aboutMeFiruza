//
//  WeatherService.swift

import Foundation

protocol WeatherServiceProtocol {
    func fetchCurrentWeather(city: String) async throws -> CurrentWeather
    func fetchForecast(city: String) async throws -> ForecastResponse
}

class WeatherService: WeatherServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func fetchCurrentWeather(city: String) async throws -> CurrentWeather {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let endpoint = "\(baseURL)/weather?q=\(encodedCity)&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            return try JSONDecoder().decode(CurrentWeather.self, from: data)
        } catch let decodingError as DecodingError {
            throw APIError.networkError(decodingError)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func fetchForecast(city: String) async throws -> ForecastResponse {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let endpoint = "\(baseURL)/forecast?q=\(encodedCity)&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            return try JSONDecoder().decode(ForecastResponse.self, from: data)
        } catch let decodingError as DecodingError {
            throw APIError.networkError(decodingError)
        } catch {
            throw APIError.networkError(error)
        }
    }
  
    
   
    
   
}
