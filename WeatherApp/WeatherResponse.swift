import Foundation

// Main data model for the weather response
struct WeatherResponse: Codable {
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let sys: Sys
    let name: String
    
    struct Main: Codable {
        let temp: Double
        let pressure: Double
        let humidity: Int
    }
    
    struct Weather: Codable {
        let description: String
        let main: String
    }
    
    struct Wind: Codable {
        let speed: Int  
    }
    
    struct Sys: Codable {
        let country: String
        let sunrise: Int
        let sunset: Int
    }
}
