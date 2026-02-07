import Foundation

class WeatherManager {
    private var apiKey: String {
        return Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
    }
    
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let forecastURL = "https://api.openweathermap.org/data/2.5/forecast"

    func fetchWeather(for city: String, unit: String, completion: @escaping (WeatherResponse?) -> Void) {
        guard !apiKey.isEmpty else { return }
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let urlString = "\(baseURL)?q=\(encodedCity)&appid=\(apiKey)&units=\(unit)"
        guard let url = URL(string: urlString) else { completion(nil); return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                var decoded = try? JSONDecoder().decode(WeatherResponse.self, from: data)
                decoded?.lastUpdated = Date() // Mark the time of fetch
                DispatchQueue.main.async { completion(decoded) }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }

    func fetchForecast(for city: String, unit: String, completion: @escaping ([ForecastResponse]?) -> Void) {
        guard !apiKey.isEmpty else { return }
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let urlString = "\(forecastURL)?q=\(encodedCity)&appid=\(apiKey)&units=\(unit)"
        guard let url = URL(string: urlString) else { completion(nil); return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(ForecastAPIResponse.self, from: data) {
                    let dailyData = stride(from: 0, to: decoded.list.count, by: 8).map { decoded.list[$0] }
                    DispatchQueue.main.async { completion(Array(dailyData.prefix(3))) }
                }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }

    // MARK: - Local Persistence
    func saveToCache(weather: WeatherResponse?, forecast: [ForecastResponse]) {
        let encoder = JSONEncoder()
        if let weather = weather, let encodedW = try? encoder.encode(weather) {
            UserDefaults.standard.set(encodedW, forKey: "cached_weather")
        }
        if let encodedF = try? encoder.encode(forecast) {
            UserDefaults.standard.set(encodedF, forKey: "cached_forecast")
        }
    }

    func loadCachedWeather() -> WeatherResponse? {
        guard let data = UserDefaults.standard.data(forKey: "cached_weather") else { return nil }
        return try? JSONDecoder().decode(WeatherResponse.self, from: data)
    }

    func loadCachedForecast() -> [ForecastResponse] {
        guard let data = UserDefaults.standard.data(forKey: "cached_forecast") else { return [] }
        return (try? JSONDecoder().decode([ForecastResponse].self, from: data)) ?? []
    }
}
