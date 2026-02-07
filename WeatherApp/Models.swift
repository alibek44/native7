import Foundation

// Assignment 8 Requirement: id, name, createdAt, createdBy (uid) [cite: 25]
struct FavoriteCity: Identifiable, Codable {
    var id: String
    var cityName: String
    var note: String
    var createdAt: Double
    var createdBy: String
}

struct WeatherResponse: Codable {
    let name: String
    let sys: Sys
    let main: Main
    let weather: [Weather]
    let wind: Wind
    var lastUpdated: Date?
}

struct ForecastAPIResponse: Codable {
    let list: [ForecastResponse]
}

struct ForecastResponse: Codable {
    let dt: Int
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let dt_txt: String
}

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
