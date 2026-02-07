import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var fbManager = FirebaseManager()
    @State private var favoriteNote: String = ""
    
    // Track which favorite is currently in "Edit Mode"
    @State private var editingFavoriteId: String? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                        // Search Bar
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

                        // Current Weather & Save Section
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
                                
                                VStack(spacing: 10) {
                                    TextField("Add a note (e.g. Best season)", text: $favoriteNote)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Button(action: {
                                        fbManager.addFavorite(cityName: weather.name, note: favoriteNote)
                                        favoriteNote = ""
                                    }) {
                                        Label("Save to Firebase Favorites", systemImage: "star.fill")
                                            .padding(10)
                                            .frame(maxWidth: .infinity)
                                            .background(fbManager.userId == nil ? Color.gray : Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                    .disabled(fbManager.userId == nil)
                                    
                                    if fbManager.userId == nil {
                                        Text("Connecting to Firebase...")
                                            .font(.caption).foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }

                        // Forecast Section
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
                        
                        // Assignment 8: Cloud Favorites List with Edit Button
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Cloud Favorites")
                                .font(.title2).bold()
                                .padding(.horizontal)
                            
                            if fbManager.favorites.isEmpty {
                                Text("No favorites saved in the cloud.")
                                    .font(.subheadline).foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            ForEach(fbManager.favorites) { fav in
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(fav.cityName).font(.headline)
                                            // Show live weather for favorite if available
                                            if let temp = fbManager.favoriteWeather[fav.id]?.main.temp {
                                                Text("\(Int(temp))°").foregroundColor(.blue).bold()
                                            }
                                        }
                                        
                                        if editingFavoriteId == fav.id {
                                            // EDIT MODE: Note is a TextField
                                            TextField("Edit note", text: Binding(
                                                get: { fav.note },
                                                set: { fbManager.updateFavoriteNote(id: fav.id, newNote: $0) }
                                            ))
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .font(.subheadline)
                                        } else {
                                            // VIEW MODE: Note is static text
                                            Text(fav.note)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Edit/Update Toggle Button
                                    Button(action: {
                                        if editingFavoriteId == fav.id {
                                            editingFavoriteId = nil // Close edit mode (Save)
                                        } else {
                                            editingFavoriteId = fav.id // Open edit mode
                                        }
                                    }) {
                                        Image(systemName: editingFavoriteId == fav.id ? "checkmark.circle.fill" : "pencil.circle")
                                            .font(.title3)
                                            .foregroundColor(editingFavoriteId == fav.id ? .green : .blue)
                                    }

                                    // Delete Button
                                    Button(action: { fbManager.deleteFavorite(id: fav.id) }) {
                                        Image(systemName: "trash").font(.title3).foregroundColor(.red)
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
            .onAppear {
                viewModel.checkInitialCache()
                // Fetch weather for list items when view appears
                fbManager.fetchWeatherForFavorites(weatherManager: viewModel.weatherManager, unit: viewModel.unit)
            }
            // Update weather if favorite list changes
            .onChange(of: fbManager.favorites.count) { _ in
                fbManager.fetchWeatherForFavorites(weatherManager: viewModel.weatherManager, unit: viewModel.unit)
            }
        }
    }
}
