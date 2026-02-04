import Foundation

class WeatherManager {
    
    private var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String ?? ""
    }
    
    private let baseURL = "https://api.openweathermap.org/data/2.5/"
    
    // Fetch weather data for the current day
    func fetchWeather(for city: String, unit: String, completion: @escaping (WeatherResponse?) -> Void) {
        let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "\(baseURL)weather?q=\(cityEncoded)&appid=\(apiKey)&units=\(unit)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Network error:", error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(weather)
            } catch {
                print("Decoding error:", error)
                completion(nil)
            }
        }.resume()
    }
    
    // Fetch 3-day forecast data
    func fetchForecast(for city: String, unit: String, completion: @escaping ([ForecastResponse]?) -> Void) {
        let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "\(baseURL)forecast?q=\(cityEncoded)&appid=\(apiKey)&units=\(unit)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Network error:", error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                // Decode the forecast API response, which contains the 'list' array
                let forecastData = try JSONDecoder().decode(ForecastAPIResponse.self, from: data)
                completion(forecastData.list)  // Return the list of forecast data
            } catch {
                print("Decoding error:", error)
                completion(nil)
            }
        }.resume()
    }}
