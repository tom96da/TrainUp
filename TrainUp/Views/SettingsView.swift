//
//  SettingsView.swift
//  TrainUp
//
//  Created by tom96da on 2024/12/21.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("username") var username: String = ""
    @State private var tempUsername: String = ""
    var body: some View {
        Form {
            Section(header: Text("User")) {
                HStack {
                    TextField("Username", text: $tempUsername)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Save") {
                        if (!tempUsername.isEmpty) {
                            username = tempUsername
                        }
                    }
                }
            }
            Section(header: Text("Language")) {
                Picker("Language", selection: $languageManager.selectedLanguage) {
                    Text("English").tag("en")
                    Text("Japanese").tag("ja")
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: languageManager.selectedLanguage) { oldValue, newValue in
                    languageManager.updateLanguage(to: newValue)
                }
            }
            Section(header: Text("Widget Update Frequency")) {
                @AppStorage("updateFrequency") var updateFrequency: Double = 60.0
                Picker("Update Frequency", selection: $updateFrequency) {
                    Text("1 min").tag(60.0)
                    Text("5 min").tag(300.0)
                    Text("10 min").tag(600.0)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section (footer: Text("This app requires location permission \"allways\" to fetch nearest station in widget.")) {
                Button(action: {
                    openAppSettings()
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Open App Settings")
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            tempUsername = username // ユーザー名を初期化
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
