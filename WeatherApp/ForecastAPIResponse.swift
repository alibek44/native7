import Foundation

// This is the response that contains the 'list' array
struct ForecastAPIResponse: Codable {
    let list: [ForecastResponse] // 'list' contains the forecast entries
}

// This struct represents the forecast for each day
struct ForecastResponse: Codable {
    let dt_txt: String   // The timestamp for the forecast
    let main: ForecastMain
    let weather: [Weather]
    let wind: Wind        // Wind data for the forecasted day
}

struct ForecastMain: Codable {
    let temp: Double
    let humidity: Int
}

struct Weather: Codable {
    let description: String
}

struct Wind: Codable {
    let speed: Double
}
