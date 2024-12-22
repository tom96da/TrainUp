//
// APIService.swift
// TrainUp
//
// Created by tom96da on 2024/12/21.

import Foundation

class APIService {
    static let baseURL = "https://watsxn.tom96da.com/trainup/api/v1/geo"

    static func fetchNearestStations(latitude: Double, longitude: Double, completion: @escaping (Result<[Station], Error>) -> Void) {
        let username = UserDefaults.standard.string(forKey: "username") ?? "guest"
        guard let url = URL(string: "\(baseURL)?lat=\(latitude)&lon=\(longitude)&user=\(username)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        print("url: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching stations: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let stationResponse = try decoder.decode(StationResponse.self, from: data)
                completion(.success(stationResponse.stations))
                print("Stations list: \(stationResponse.stations.map { $0.name })")
            } catch {
                print("Error decoding JSON: \(error)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

struct StationResponse: Codable {
    let stations: [Station]
}
