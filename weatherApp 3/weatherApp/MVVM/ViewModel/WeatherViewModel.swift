//
//  WeatherViewModel.swift

import Foundation
import SwiftUI

@MainActor
class WeatherViewModel: ObservableObject {
    // Published properties
    @Published var cityName: String = "Almaty"
    @Published var currentWeatherState: LoadingState<CurrentWeather> = .idle
    @Published var forecastState: LoadingState<ForecastResponse> = .idle
    @Published var errorMessage: String?
    @Published var isRefreshing = false
    
    // Service
    private let weatherService: WeatherServiceProtocol
    
    // Task management for cancellation
    private var currentTasks = [UUID: Task<Void, Never>]()
    
    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }
    
    // Load all weather data concurrently
    func loadAllWeatherData() async {
        let taskId = UUID()
        let task = Task {
            // Clear previous error
            errorMessage = nil
            
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.loadCurrentWeather() }
                group.addTask { await self.loadForecast() }
            }
            
            // Remove task from dictionary when complete
            self.currentTasks[taskId] = nil
        }
        
        // Store task for potential cancellation
        currentTasks[taskId] = task
    }
    
    func loadCurrentWeather() async {
        currentWeatherState = .loading
        
        do {
            let weather = try await weatherService.fetchCurrentWeather(city: cityName)
            currentWeatherState = .success(weather)
        } catch {
            currentWeatherState = .failure(error)
            errorMessage = (error as? APIError)?.message ?? error.localizedDescription
        }
    }
    
    func loadForecast() async {
        forecastState = .loading
        
        do {
            let forecast = try await weatherService.fetchForecast(city: cityName)
            forecastState = .success(forecast)
        } catch {
            forecastState = .failure(error)
            errorMessage = (error as? APIError)?.message ?? error.localizedDescription
        }
    }
    
    func refresh() async {
        isRefreshing = true
        
        // Cancel any ongoing tasks
        cancelAllTasks()
        
        // Load all data concurrently
        await loadAllWeatherData()
        
        isRefreshing = false
    }
    
    func updateCity(_ newCity: String) async {
        guard !newCity.isEmpty, newCity != cityName else { return }
        
        // Update city name
        cityName = newCity
        
        // Cancel ongoing tasks
        cancelAllTasks()
        
        // Reset loading states
        currentWeatherState = .idle
        forecastState = .idle
        
        // Load data for new city
        await loadAllWeatherData()
    }
    
    private func cancelAllTasks() {
        for (_, task) in currentTasks {
            task.cancel()
        }
        currentTasks.removeAll()
    }
    
    // Helper formatting methods
    func formatTemperature(_ temp: Double) -> String {
        return "\(Int(round(temp)))°C"
    }
    
    func formatDate(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formatTime(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    func getDayFromTimestamp(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    func getWeatherIcon(_ icon: String) -> String {
        // Map OpenWeatherMap icon codes to SF Symbols
        switch icon {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "cloud.fill"
        case "09d", "09n": return "cloud.rain.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "questionmark.circle"
        }
    }
}
