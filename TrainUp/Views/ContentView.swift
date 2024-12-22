//
//  ContentView.swift
//  TrainUp
//
//  Created by tom96da on 2024/12/21.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var stations: [Station] = []
    @State private var currentStationIndex = 0
    @State private var dragOffset: CGSize = .zero
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("username") private var username: String = ""
    @AppStorage("updateFrequency") private var updateFrequency: Double = 60.0
    @State private var cancellable: AnyCancellable?
    private let sharedDefaults = UserDefaults(suiteName: "group.com.tom96da.watsxn.TrainUp")

    var body: some View {
        NavigationView {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 300, height: 300)
                    .onTapGesture {
                        if let loc = locationManager.location {
                            fetchNearestStations(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                        }
                    }
                    .gesture(DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            // Threshold of scroll amount
                            let threshold: CGFloat = 50
                            if value.translation.width > threshold {
                                // swipe right
                                currentStationIndex = (currentStationIndex - 1 + stations.count) % stations.count
                            } else if value.translation.width < -threshold {
                                // swipe left
                                currentStationIndex = (currentStationIndex + 1) % stations.count
                            }
                            dragOffset = .zero
                        }
                    )

                if (!stations.isEmpty) {
                    VStack {
                        Text(stations[currentStationIndex].name)
                            .font(.title)
                            .foregroundColor(.white)
                        Text(stations[currentStationIndex].line)
                            .foregroundColor(.white)
                        Text(stations[currentStationIndex].distance)
                            .foregroundColor(.white)
                    }
                } else {
                    Text("Tap to search station")
                        .font(.title)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }

                VStack {
                    Spacer()
                    HStack {
                        ForEach(0..<stations.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentStationIndex ? Color.black : Color.gray)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarItems(trailing: NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
                    .imageScale(.large)
            })
            .onAppear {
                locationManager.requestLocationAuthorization()
                startPeriodicFetch()
            }
            .onChange(of: updateFrequency) { oldValue, newValue in
                startPeriodicFetch()
            }
        }
    }

    private func startPeriodicFetch() {
        cancellable?.cancel()
        cancellable = Timer.publish(every: updateFrequency, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if let loc = locationManager.location {
                    print("Periodic fetch...")
                    fetchNearestStations(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                }
            }
        print("set timer for \(updateFrequency) seconds")
    }

    private func fetchNearestStations(latitude: Double, longitude: Double) {
        APIService.fetchNearestStations(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let fetchedStations):
                DispatchQueue.main.async {
                    self.stations = fetchedStations
                    self.currentStationIndex = 0
                    saveStationsForWidget(fetchedStations)
                }
            case .failure(let error):
                print("Error fetching stations: \(error)")
            }
        }
    }

    private func saveStationsForWidget(_ stations: [Station]) {
        if let encoded = try? JSONEncoder().encode(stations) {
            sharedDefaults?.set(encoded, forKey: "widgetStations") // 共有UserDefaultsに保存
        }
    }
}
