import SwiftUI

struct SettingsView: View {
    @Environment(LanguageStore.self) private var lang
    @Environment(PreferencesStore.self) private var prefs
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var lang = lang

        NavigationStack {
            Form {
                Section(lang.tr(.settingsLanguage)) {
                    Picker(lang.tr(.settingsLanguage), selection: $lang.current) {
                        ForEach(Language.allCases) { language in
                            HStack {
                                Text(language.flag)
                                Text(language.nativeName)
                            }
                            .tag(language)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section(lang.tr(.menuAlphabets)) {
                    ForEach(Script.allCases) { script in
                        Toggle(script.label, isOn: Binding(
                            get: { prefs.selectedScripts.contains(script) },
                            set: { _ in prefs.toggle(script) }
                        ))
                    }
                }
            }
            .navigationTitle(lang.tr(.settingsTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.tr(.settingsDone)) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(LanguageStore())
        .environment(PreferencesStore())
}
