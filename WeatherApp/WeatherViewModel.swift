import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var forecast: [ForecastResponse] = []
    @Published var errorMessage: String? = nil
    
    // Bindings for the View
    @Published var city: String = ""
    @Published var unit: String = "metric"

    private let weatherManager = WeatherManager()

    func fetchAllData() {
        guard !city.isEmpty else {
            self.errorMessage = "Please enter a city name."
            return
        }
        
        weatherManager.fetchWeather(for: city, unit: unit) { [weak self] data in
            if let data = data {
                self?.weather = data
                self?.errorMessage = nil
                self?.weatherManager.saveWeatherData(data)
            } else {
                self?.errorMessage = "City not found."
            }
        }

        weatherManager.fetchForecast(for: city, unit: unit) { [weak self] data in
            if let data = data {
                self?.forecast = data
                self?.weatherManager.saveForecastData(data)
            }
        }
    }

    func loadCache() {
        if let cachedWeather = weatherManager.loadWeatherData() {
            self.weather = cachedWeather
        }
        if let cachedForecast = weatherManager.loadForecastData() {
            self.forecast = cachedForecast
        }
    }
}
