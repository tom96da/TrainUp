//
// LocationManager.swift
// TrainUp
//
// Created by tom96da on 2024/12/21.

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager: CLLocationManager
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    private var locationUpdateTimer: Timer?

    override init() {
        self.locationManager = CLLocationManager()
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        self.locationManager.delegate = self
        requestLocationAuthorization()
    }

    func requestLocationAuthorization() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if authorizationStatus == .denied {
        } else {
            startUpdatingLocation()
        }
    }

    func requestLocation() {
        locationManager.requestLocation()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func schedulePeriodicLocationUpdates() {
        locationUpdateTimer?.invalidate()
        let freq = UserDefaults.standard.double(forKey: "updateFrequency")
        let interval = freq > 0 ? freq : 60.0
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.requestLocation()
        }
        if let timer = locationUpdateTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        self.location = newLocation
        print("Location updated: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
        UserDefaults.standard.set([newLocation.coordinate.latitude, newLocation.coordinate.longitude], forKey: "LastKnownLocation")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            startUpdatingLocation()
            schedulePeriodicLocationUpdates()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error)")
    }
}
