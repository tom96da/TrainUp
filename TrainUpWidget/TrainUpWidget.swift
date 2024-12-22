//
//  TrainUpWidget.swift
//  TrainUpWidget
//
//  Created by tom96da on 2024/12/22.
//

import WidgetKit
import SwiftUI
import CoreLocation

struct StationWidgetEntry: TimelineEntry {
    let date: Date
    let station: Station?
}

struct StationWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> StationWidgetEntry {
        StationWidgetEntry(date: Date(), station: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (StationWidgetEntry) -> Void) {
        let mockStation = Station(name: "Station", line: "JR", distance: "0m", lat: 35.0, lon: 139.0)
        completion(StationWidgetEntry(date: Date(), station: mockStation))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StationWidgetEntry>) -> Void) {
        let currentDate = Date()
        let updateFrequency = UserDefaults.standard.double(forKey: "updateFrequency")

        if let stored = UserDefaults.standard.array(forKey: "LastKnownLocation") as? [Double],
           stored.count == 2 {
            let latitude = stored[0]
            let longitude = stored[1]
            print("LastKnownLocation: \(latitude), \(longitude)")
            APIService.fetchNearestStations(latitude: latitude, longitude: longitude) { result in
                let station: Station?
                switch result {
                case .success(let stations):
                    station = stations.first
                case .failure:
                    station = nil
                }
                let entry = StationWidgetEntry(date: currentDate, station: station)
                let timeline = Timeline(entries: [entry], policy: .after(currentDate.addingTimeInterval(updateFrequency)))
                completion(timeline)
            }
        } else {
            let entry = StationWidgetEntry(date: currentDate, station: nil)
            let timeline = Timeline(entries: [entry], policy: .after(currentDate.addingTimeInterval(updateFrequency)))
            completion(timeline)
        }
    }
}

struct TrainUpWidgetEntryView: View {
    var entry: StationWidgetEntry

    var body: some View {
        if let station = entry.station {
            VStack {
                Text(station.name)
                    .font(.headline)
                Text(station.line)
            }
            .containerBackground(.fill.tertiary, for: .widget)
        } else {
            Text("No Station")
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

struct TrainUpWidget: Widget {
    let kind: String = "TrainUpWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StationWidgetProvider()) { entry in
            TrainUpWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TrainUp Widget")
        .description("Display nearest station info")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge,
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    TrainUpWidget()
} timeline: {
    StationWidgetEntry(date: .now, station: Station(name: "御茶ノ水", line: "JR中央線", distance: "100m", lat: 35.0, lon: 139.0))
}
