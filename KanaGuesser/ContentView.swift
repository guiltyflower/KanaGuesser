//
//  ContentView.swift
//  KanaGuesser
//

import SwiftUI

enum AppMode {
    case menu
    case learn
    case multiplayer
}

struct ContentView: View {
    @State private var mode: AppMode = .menu
    @State private var showSettings = false

    @Environment(PreferencesStore.self) private var prefs

    var body: some View {
        Group {
            switch mode {
            case .menu:
                MenuView(
                    onLearn: { mode = .learn },
                    onMultiplayer: { mode = .multiplayer },
                    onSettings: { showSettings = true }
                )
            case .learn:
                LearnView(scripts: prefs.selectedScripts) { mode = .menu }
            case .multiplayer:
                MultiplayerView(scripts: prefs.selectedScripts) { mode = .menu }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

private struct MenuView: View {
    let onLearn: () -> Void
    let onMultiplayer: () -> Void
    let onSettings: () -> Void

    @Environment(LanguageStore.self) private var lang

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 6) {
                    Text("KanaGuesser")
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                    Text(lang.tr(.menuSubtitle))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 14) {
                    modeButton(
                        title: lang.tr(.modeLearnTitle),
                        subtitle: lang.tr(.modeLearnSubtitle),
                        system: "book.fill",
                        tint: .accentColor,
                        action: onLearn
                    )

                    modeButton(
                        title: lang.tr(.modeChallengeTitle),
                        subtitle: lang.tr(.modeChallengeSubtitle),
                        system: "person.2.fill",
                        tint: .orange,
                        action: onMultiplayer
                    )
                }
                .padding(.horizontal, 8)

                Spacer()
            }
            .padding(24)

            Button(action: onSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
            .padding(.trailing, 16)
            .accessibilityLabel(lang.tr(.settingsTitle))
        }
    }

    private func modeButton(
        title: String,
        subtitle: String,
        system: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: system)
                    .font(.title.bold())
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(tint.opacity(0.15)))
                    .foregroundStyle(tint)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.tertiary)
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environment(LanguageStore())
        .environment(PreferencesStore())
}
