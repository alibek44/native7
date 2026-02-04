import SwiftUI
import Combine

class WeatherViewModel: ObservableObject {

    @Published var weather: WeatherResponse?
    @Published var city: String = "Almaty"
    @Published var errorMessage: String?
    @Published var unit: String = "metric"
    @Published var forecast: [ForecastResponse] = [] // Store the 3-day forecast

    private let manager = WeatherManager()

    // Fetch current weather
    func fetchWeather() {
        manager.fetchWeather(for: city, unit: unit) { [weak self] result in
            DispatchQueue.main.async {  // Ensure UI updates happen on the main thread
                if let result = result {
                    self?.weather = result
                    self?.errorMessage = nil
                } else {
                    self?.weather = nil
                    self?.errorMessage = "City not found or API error"
                }
            }
        }
    }
    
    // Fetch 3-day forecast and filter data to show only one entry per day
    func fetchForecast() {
        manager.fetchForecast(for: city, unit: unit) { [weak self] forecastData in
            DispatchQueue.main.async {  // Ensure UI updates happen on the main thread
                if let forecastData = forecastData {
                    // Filter the forecast data to include only one entry per day (average)
                    let filteredForecast = self?.filterForecastData(forecastData)
                    self?.forecast = filteredForecast ?? []
                    self?.errorMessage = nil
                } else {
                    self?.forecast = []
                    self?.errorMessage = "Unable to fetch forecast data"
                }
            }
        }
    }

    // Filter the forecast data to show one entry per day (next 3 days)
    private func filterForecastData(_ forecastData: [ForecastResponse]) -> [ForecastResponse] {
        var uniqueDates: Set<String> = Set()
        var filteredForecast: [ForecastResponse] = []

        // Loop through the forecast data and pick one entry per day
        for forecast in forecastData {
            let date = String(forecast.dt_txt.prefix(10))  // Get only the date part (yyyy-MM-dd)
            
            if !uniqueDates.contains(date) {
                uniqueDates.insert(date)  // Ensure unique dates
                filteredForecast.append(forecast)
                
                // Stop after getting 3 days of forecast
                if filteredForecast.count == 3 {
                    break
                }
            }
        }
        
        return filteredForecast
    }
}
