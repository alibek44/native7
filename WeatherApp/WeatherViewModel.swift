import Foundation
import Combine
class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var forecast: [ForecastResponse] = []
    @Published var isOffline: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var city: String = ""
    @Published var unit: String = "metric"

    private let weatherManager = WeatherManager()

    func fetchAllData() {
        guard !city.isEmpty else { return }
        
        weatherManager.fetchWeather(for: city, unit: unit) { [weak self] weatherData in
            if let data = weatherData {
                // Success: Update UI and Cache
                self?.weather = data
                self?.isOffline = false
                self?.errorMessage = nil
                
                // Fetch forecast only if weather succeeds
                self?.weatherManager.fetchForecast(for: self!.city, unit: self!.unit) { forecastData in
                    self?.forecast = forecastData ?? []
                    self?.weatherManager.saveToCache(weather: self?.weather, forecast: self?.forecast ?? [])
                }
            } else {
                // Failure: Try Cache
                self?.tryLoadingOfflineData()
            }
        }
    }

    func tryLoadingOfflineData() {
        let cachedW = weatherManager.loadCachedWeather()
        let cachedF = weatherManager.loadCachedForecast()
        
        if cachedW != nil {
            self.weather = cachedW
            self.forecast = cachedF
            self.isOffline = true
            self.errorMessage = "Internet unavailable. Showing last saved data."
        } else {
            self.errorMessage = "No internet connection and no cached data found."
        }
    }

    func checkInitialCache() {
        if let cachedW = weatherManager.loadCachedWeather() {
            self.weather = cachedW
            self.forecast = weatherManager.loadCachedForecast()
            self.isOffline = true // Assume offline until user searches
        }
    }
}
