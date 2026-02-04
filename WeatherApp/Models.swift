import Foundation

struct WeatherResponse: Codable {
    let name: String
    let sys: Sys
    let main: Main
    let weather: [Weather]
    let wind: Wind
}

struct ForecastAPIResponse: Codable {
    let list: [ForecastResponse]
}

struct ForecastResponse: Codable {
    let dt: Int // Essential for the SwiftUI ForEach ID
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let dt_txt: String
}

// Shared Structs
struct Main: Codable {
    let temp: Double
    let humidity: Int
    let pressure: Int
}

struct Weather: Codable {
    let description: String
}

struct Wind: Codable {
    let speed: Double
}

struct Sys: Codable {
    let country: String
}
