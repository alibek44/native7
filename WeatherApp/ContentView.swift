import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()  // Use StateObject for WeatherViewModel

    var body: some View {
        TabView {
            // Weather Tab
            VStack {
                TextField("Enter city", text: $viewModel.city)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Get Weather") {
                    viewModel.fetchWeather()
                    viewModel.fetchForecast()  // Fetch forecast after getting the weather
                }
                .padding()
                
                if let weather = viewModel.weather {
                    Text("City: \(weather.name), \(weather.sys.country)")
                    Text("Temperature: \(weather.main.temp, specifier: "%.1f")°")
                    Text("Condition: \(weather.weather.first?.description ?? "Unknown")")
                    Text("Humidity: \(weather.main.humidity)%")
                    Text("Wind Speed: \(weather.wind.speed) m/s")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                }

                // Display forecast for the next 3 days
                if !viewModel.forecast.isEmpty {
                    ForEach(viewModel.forecast, id: \.dt_txt) { day in
                        VStack(alignment: .leading) {
                            Text("\(String(day.dt_txt.prefix(10))):")
                                .font(.headline)
                            Text("Temp: \(day.main.temp, specifier: "%.1f")°C")
                            Text("Condition: \(day.weather.first?.description ?? "Unknown")")
                            Text("Wind Speed: \(day.wind.speed) m/s")
                            Text("Humidity: \(day.main.humidity)%")
                        }
                        .padding(.top, 5)
                    }
                }
            }
            .tabItem {
                Label("Weather", systemImage: "cloud.sun.fill")
            }
            
            // Settings Tab (Example, extend this if needed)
            VStack {
                Text("Settings Tab")
                    .font(.title)
                    .padding()
                Text("Adjust your preferences here.")
                    .padding()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .onAppear {
            viewModel.fetchWeather()  // Load weather data on first launch
        }
    }
}

