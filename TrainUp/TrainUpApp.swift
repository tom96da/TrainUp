//
//  TrainUpApp.swift
//  TrainUp
//
//  Created by tom96da on 2024/12/21.
//

import SwiftUI

@main
struct TrainUpApp: App {
    @StateObject private var languageManager = LanguageManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, Locale(identifier: languageManager.selectedLanguage))
                .environmentObject(languageManager)
        }
    }
}
