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
    private let sharedDefaults = UserDefaults(suiteName: "group.com.tom96da.watsxn.TrainUp")

    func placeholder(in context: Context) -> StationWidgetEntry {
        StationWidgetEntry(date: Date(), station: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (StationWidgetEntry) -> Void) {
        let mockStation = Station(name: "Station", line: "JR", distance: "0m", lat: 35.0, lon: 139.0)
        completion(StationWidgetEntry(date: Date(), station: mockStation))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StationWidgetEntry>) -> Void) {
        let currentDate = Date()
        let updateFrequency = sharedDefaults?.double(forKey: "updateFrequency") ?? 60.0

        if let data = sharedDefaults?.data(forKey: "widgetStations"),
           let stations = try? JSONDecoder().decode([Station].self, from: data),
           let station = stations.first {
            let entry = StationWidgetEntry(date: currentDate, station: station)
            let timeline = Timeline(entries: [entry], policy: .after(currentDate.addingTimeInterval(updateFrequency)))
            completion(timeline)
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
                    .padding(.bottom, 1)
                Text(station.line)
                    .font(.subheadline)
                Text(station.distance)
                    .font(.caption)
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
        .contentMarginsDisabled()
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
