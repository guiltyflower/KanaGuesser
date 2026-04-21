//
//  KanaGuesserApp.swift
//  KanaGuesser
//
//  Created by Giovanni Fioretto on 19/04/2026.
//

import SwiftUI

@main
struct KanaGuesserApp: App {
    @State private var languageStore = LanguageStore()
    @State private var preferencesStore = PreferencesStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(languageStore)
                .environment(preferencesStore)
        }
    }
}
