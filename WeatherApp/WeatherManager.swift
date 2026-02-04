import Foundation

class WeatherManager {
    private var apiKey: String {
        guard let key = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            print("❌ Error: API_KEY not found in Info.plist")
            return ""
        }
        return key
    }
    
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let forecastURL = "https://api.openweathermap.org/data/2.5/forecast"

    func fetchWeather(for city: String, unit: String, completion: @escaping (WeatherResponse?) -> Void) {
        guard !apiKey.isEmpty else { return }
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let urlString = "\(baseURL)?q=\(encodedCity)&appid=\(apiKey)&units=\(unit)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    DispatchQueue.main.async { completion(decoded) }
                } catch {
                    print("Decoding Error: \(error)")
                    DispatchQueue.main.async { completion(nil) }
                }
            }
        }.resume()
    }

    func fetchForecast(for city: String, unit: String, completion: @escaping ([ForecastResponse]?) -> Void) {
        guard !apiKey.isEmpty else { return }
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let urlString = "\(forecastURL)?q=\(encodedCity)&appid=\(apiKey)&units=\(unit)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(ForecastAPIResponse.self, from: data)
                    // Filter: take one reading every 24 hours (8 * 3hr intervals)
                    let dailyData = stride(from: 0, to: decoded.list.count, by: 8).map { decoded.list[$0] }
                    DispatchQueue.main.async { completion(Array(dailyData.prefix(3))) }
                } catch {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
        }.resume()
    }

    // MARK: - Caching
    func saveWeatherData(_ data: WeatherResponse) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "weatherData")
        }
    }

    func loadWeatherData() -> WeatherResponse? {
        guard let data = UserDefaults.standard.data(forKey: "weatherData") else { return nil }
        return try? JSONDecoder().decode(WeatherResponse.self, from: data)
    }

    func saveForecastData(_ data: [ForecastResponse]) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "forecastData")
        }
    }

    func loadForecastData() -> [ForecastResponse]? {
        guard let data = UserDefaults.standard.data(forKey: "forecastData") else { return nil }
        return try? JSONDecoder().decode([ForecastResponse].self, from: data)
    }
}
