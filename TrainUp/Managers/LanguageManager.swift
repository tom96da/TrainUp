//
//  LanguageManager.swift
//  TrainUp
//
//  Created by tom96da on 2024/12/21.
//

import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    @AppStorage("selectedLanguage") var selectedLanguage: String = Locale.current.language.languageCode?.identifier ?? "ja" {
        didSet {
            UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    
    func updateLanguage(to language: String) {
        selectedLanguage = language
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
