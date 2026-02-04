import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    TextField("Enter city (e.g. London)", text: $viewModel.city)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: { viewModel.fetchAllData() }) {
                        Image(systemName: "magnifyingglass")
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()

                // Unit Toggle
                Picker("Unit", selection: $viewModel.unit) {
                    Text("Celsius").tag("metric")
                    Text("Fahrenheit").tag("imperial")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                if let weather = viewModel.weather {
                    CurrentWeatherCard(weather: weather)
                }

                if !viewModel.forecast.isEmpty {
                    Text("3-Day Forecast")
                        .font(.headline)
                        .padding(.top)

                    List(viewModel.forecast, id: \.dt) { day in
                        HStack {
                            Text(day.dt_txt.prefix(10)) // Simple date display
                            Spacer()
                            Text("\(day.main.temp, specifier: "%.1f")°")
                            Text(day.weather.first?.description.capitalized ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Weather")
            .onAppear { viewModel.loadCache() }
        }
    }
}

struct CurrentWeatherCard: View {
    let weather: WeatherResponse
    var body: some View {
        VStack(spacing: 10) {
            Text(weather.name)
                .font(.largeTitle)
                .bold()
            Text("\(weather.main.temp, specifier: "%.1f")°")
                .font(.system(size: 60))
            Text(weather.weather.first?.description.capitalized ?? "")
                .font(.title3)
            HStack {
                Text("Humidity: \(weather.main.humidity)%")
                Text("Wind: \(weather.wind.speed, specifier: "%.1f") m/s")
            }
            .font(.subheadline)
        }
        .padding()
    }
}
