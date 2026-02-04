import Foundation

class CacheManager {
    static let shared = CacheManager()
    
    private init() {}
    
    // Save weather data to UserDefaults
    func saveWeatherData(weatherData: WeatherResponse) {
        if let encodedData = try? JSONEncoder().encode(weatherData) {
            UserDefaults.standard.set(encodedData, forKey: "lastWeatherData")
        }
    }
    
    // Load weather data from UserDefaults
    func loadWeatherData() -> WeatherResponse? {
        if let data = UserDefaults.standard.data(forKey: "lastWeatherData") {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(WeatherResponse.self, from: data) {
                return decodedData
            }
        }
        return nil
    }
}
