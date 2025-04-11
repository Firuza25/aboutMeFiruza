//
//  ContentView.swift

import SwiftUI
struct ContentView: View {
    @StateObject private var viewModel: WeatherViewModel
    @State private var searchText = ""

    init(apiKey: String) {
        let weatherService = WeatherService(apiKey: apiKey)
        _viewModel = StateObject(wrappedValue: WeatherViewModel(weatherService: weatherService))
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(hex: "1E1E46"), Color(hex: "2D1B4E")],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        searchBar
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        mainWeatherPanel

                        todayHourlyForecast
                        
 
                        forecastPanel
                        
                        airQualityPanel
                        

                        sunInfoPanel
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .task {
                await viewModel.loadAllWeatherData()
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Введите город", text: $searchText)
                .padding()
                .background(Color(hex: "3A2967").opacity(0.6))
                .foregroundColor(.white)           // Explicitly setting text color to white
                .accentColor(.white)               // Setting cursor and selection color to white
                .cornerRadius(15)
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        await viewModel.updateCity(searchText)
                        searchText = ""
                    }
                }
                // Adding a text modifier to ensure placeholder text is also white
                .modifier(PlaceholderStyleModifier(showPlaceHolder: searchText.isEmpty,
                                                   placeholder: "Введите город",
                                                   color: .white.opacity(0.7)))

            Button {
                Task {
                    await viewModel.updateCity(searchText)
                    searchText = ""
                }
            } label: {
                Image(systemName: "magnifyingglass")
                    .padding(12)
                    .background(Color(hex: "7A57D1"))
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
        }
    }
    
    private var mainWeatherPanel: some View {
        Group {
            switch viewModel.currentWeatherState {
            case .success(let weather):
                VStack(spacing: 20) {
                    // Centered city information
                    Text("\(weather.name), \(weather.sys.country)")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    // Centered weather information
                    VStack(spacing: 16) {
                        if let condition = weather.weather.first {
                            Image(systemName: viewModel.getWeatherIcon(condition.icon))
                                .font(.system(size: 80))
                                .foregroundColor(.yellow)
                        }
                        
                        Text(viewModel.formatTemperature(weather.main.temp).replacingOccurrences(of: "°C", with: "°"))
                            .font(.system(size: 70, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if let condition = weather.weather.first {
                            Text(condition.description.capitalized)
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        
                        Text("Precipitations")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.body)
                            .padding(.top, 4)
                        
                        Text("Max: \(viewModel.formatTemperature(weather.main.temp_max).replacingOccurrences(of: "°C", with: "°"))   Min: \(viewModel.formatTemperature(weather.main.temp_min).replacingOccurrences(of: "°C", with: "°"))")
                            .foregroundColor(.white)
                            .font(.body)
                    }
                    
                    Spacer(minLength: 40)
                    
                    HStack {
                        Text("Today")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(viewModel.formatDateMonthDay(weather.dt))
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 20)

            case .loading:
                ProgressView("Загрузка...")
                    .frame(height: 300)
                    .foregroundColor(.white)

            case .failure:
                Text("Не удалось загрузить данные")
                    .foregroundColor(.white)
                    .frame(height: 300)

            case .idle:
                EmptyView()
            }
        }
    }
    
    private var todayHourlyForecast: some View {
        Group {
            switch viewModel.forecastState {
            case .success(let forecast):
                // Using more items for hourly forecast, showing full day (8 items)
                let todayForecasts = forecast.list.prefix(8)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hourly Forecast")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                    
                    // Make it scrollable horizontally with larger items
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(Array(todayForecasts.enumerated()), id: \.element.dt) { index, item in
                                VStack(spacing: 12) {
                                    Text(viewModel.formatTime(item.dt))
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    if let weather = item.weather.first {
                                        Image(systemName: viewModel.getWeatherIcon(weather.icon))
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text(viewModel.formatTemperature(item.main.temp).replacingOccurrences(of: "°C", with: "°"))
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 80, height: 150)
                                .background(Color(hex: "5F47AB").opacity(0.5))
                                .cornerRadius(20)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
            case .loading, .failure, .idle:
                EmptyView()
            }
        }
    }
    
    private var forecastPanel: some View {
        Group {
            switch viewModel.forecastState {
            case .success(let forecast):
                let dayForecasts = groupForecastByDay(forecast.list)
                                    .prefix(4)
                                    .map { day, items in
                                        (day, items.first!)
                                    }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("7-Days Forecasts")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 16) {
                        ForEach(Array(dayForecasts), id: \.0) { day, item in
                            VStack(spacing: 12) {
                                Text(viewModel.formatTemperature(item.main.temp).replacingOccurrences(of: "°C", with: "°C"))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                if let weather = item.weather.first {
                                    Image(systemName: viewModel.getWeatherIcon(weather.icon))
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                                
                                Text(viewModel.formatDayOfWeek(day))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 70, height: 100)
                            .background(Color(hex: "5F47AB"))
                            .cornerRadius(30)
                        }
                    }
                }
                .padding()
                .background(Color(hex: "433686").opacity(0.7))
                .cornerRadius(20)
                
            case .loading:
                ProgressView("Загрузка прогноза...")
                    .foregroundColor(.white)
                
            case .failure:
                Text("Ошибка при загрузке прогноза")
                    .foregroundColor(.white)
                
            case .idle:
                EmptyView()
            }
        }
    }
    
    private var airQualityPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "aqi.medium")
                    .foregroundColor(.white)
                    .font(.title3)
                Text("AIR QUALITY")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            
            Text("3-Low Health Risk")
                .font(.title3)
                .foregroundColor(.white)
                .padding(.top, 4)
            
            HStack {
                Spacer()
                Button(action: {}) {
                    HStack {
                        Text("See more")
                            .foregroundColor(.white)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "433686").opacity(0.7))
        .cornerRadius(20)
    }
    
    private var sunInfoPanel: some View {
        Group {
            switch viewModel.currentWeatherState {
            case .success(let weather):
                HStack(spacing: 16) {
                    // Sunrise panel
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "sunrise.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                            Text("SUNRISE")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        
                        Text("\(viewModel.formatTime(weather.sys.sunrise))")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text("Sunset: \(viewModel.formatTime(weather.sys.sunset))")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.43)
                    .background(Color(hex: "433686").opacity(0.7))
                    .cornerRadius(20)
                    
                    // UV Index panel
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                            Text("UV INDEX")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        
                        Text("4")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text("Moderate")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.43)
                    .background(Color(hex: "433686").opacity(0.7))
                    .cornerRadius(20)
                }
                
            case .loading, .failure, .idle:
                EmptyView()
            }
        }
    }
    
    private func groupForecastByDay(_ forecasts: [ForecastItem]) -> [(String, [ForecastItem])] {
        let grouped = Dictionary(grouping: forecasts) { item in
            viewModel.getDayFromTimestamp(item.dt)
        }
        return grouped.sorted(by: { $0.key < $1.key })
    }
}

// Custom modifier to ensure placeholder text is white
struct PlaceholderStyleModifier: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    var color: Color
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .foregroundColor(color)
                    .padding(.leading, 5)
            }
            content
        }
    }
}

// Helper extension to create colors from hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Add these methods to your ViewModel
extension WeatherViewModel {
    func formatDateMonthDay(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, d"
        return formatter.string(from: date)
    }
    
    func formatDayOfWeek(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEE"
        return weekdayFormatter.string(from: date)
    }
}
