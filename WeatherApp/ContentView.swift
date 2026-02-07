import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var fbManager = FirebaseManager() // Firebase logic
    @State private var favoriteNote: String = "" // Local state for the note field
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 1. Offline Label (Assignment 7 requirement)
                if viewModel.isOffline {
                    Label("Offline Mode", systemImage: "wifi.slash")
                        .font(.caption).bold()
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                }

                ScrollView {
                    VStack(spacing: 20) {
                        // 2. Search Bar
                        HStack {
                            TextField("Enter city", text: $viewModel.city)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit { viewModel.fetchAllData() }
                            
                            Button(action: { viewModel.fetchAllData() }) {
                                Image(systemName: "magnifyingglass.circle.fill").font(.title)
                            }
                        }
                        .padding()

                        Picker("Units", selection: $viewModel.unit) {
                            Text("Celsius").tag("metric")
                            Text("Fahrenheit").tag("imperial")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)

                        // 3. Current Weather & Add to Favorites
                        if let weather = viewModel.weather {
                            VStack(spacing: 15) {
                                VStack {
                                    Text(weather.name).font(.largeTitle).bold()
                                    Text("\(Int(weather.main.temp))°").font(.system(size: 70, weight: .thin))
                                    if let date = weather.lastUpdated {
                                        Text("Updated: \(date.formatted(date: .omitted, time: .shortened))")
                                            .font(.caption2).foregroundColor(.secondary)
                                    }
                                }
                                
                                // Assignment 8: Firebase Integration Section
                                VStack(spacing: 10) {
                                    TextField("Add a note (e.g. Best season)", text: $favoriteNote)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal)
                                    
                                    Button(action: {
                                        fbManager.addFavorite(cityName: weather.name, note: favoriteNote)
                                        favoriteNote = "" // Clear field after saving
                                    }) {
                                        Label("Save to Firebase Favorites", systemImage: "star.fill")
                                            .padding(10)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding()
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }

                        // 4. Forecast Section
                        if !viewModel.forecast.isEmpty {
                            VStack(alignment: .leading) {
                                Text("3-Day Forecast").font(.headline).padding(.leading)
                                ForEach(viewModel.forecast, id: \.dt) { day in
                                    HStack {
                                        Text(day.dt_txt.prefix(10))
                                        Spacer()
                                        Text("\(Int(day.main.temp))°")
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.1)))
                                }
                            }
                            .padding(.horizontal)
                        }
                        if let weather = viewModel.weather {
                            VStack {
                                TextField("Add a note", text: $favoriteNote)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button(action: {
                                    fbManager.addFavorite(cityName: weather.name, note: favoriteNote)
                                    favoriteNote = ""
                                }) {
                                    Text("Save to Firebase Favorites")
                                }
                                // Disable button if not authenticated to prevent the error
                                .disabled(fbManager.userId == nil)
                                
                                if fbManager.userId == nil {
                                    Text("Connecting to Firebase...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // 5. Assignment 8: Real-time Favorites List
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Cloud Favorites").font(.title2).bold()
                                Spacer()
                                if fbManager.favorites.isEmpty {
                                    Text("(Empty)").font(.caption).foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)

                            ForEach(fbManager.favorites) { fav in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(fav.cityName).font(.headline)
                                        Text(fav.note).font(.subheadline).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button(action: { fbManager.deleteFavorite(id: fav.id) }) {
                                        Image(systemName: "trash").foregroundColor(.red)
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow.opacity(0.1)))
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                        
                        if let error = viewModel.errorMessage {
                            Text(error).font(.callout).foregroundColor(.red).padding()
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Weather Cloud")
            .onAppear { viewModel.checkInitialCache() }
        }
    }
}
