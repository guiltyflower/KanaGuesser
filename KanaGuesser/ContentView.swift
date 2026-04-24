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
        ZStack {
            KanaBackground()

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
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(KG.C.bgCreamDark)
                .presentationCornerRadius(24)
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
            VStack(spacing: 0) {
                Spacer().frame(height: 160)

                VStack(spacing: 10) {
                    Text("KanaGuesser")
                        .font(KG.F.display)
                        .tracking(-1.5)
                        .foregroundStyle(KG.C.textPrimary)
                    Text(lang.tr(.menuSubtitle))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(hex: 0x5A5A50))
                }

                Spacer().frame(height: 60)

                VStack(spacing: 12) {
                    ModeCard(
                        icon: { LearnIcon() },
                        iconBg: KG.C.blueBg,
                        title: lang.tr(.modeLearnTitle),
                        subtitle: lang.tr(.modeLearnSubtitle),
                        action: onLearn
                    )
                    ModeCard(
                        icon: { ChallengeIcon() },
                        iconBg: KG.C.orangeBg,
                        title: lang.tr(.modeChallengeTitle),
                        subtitle: lang.tr(.modeChallengeSubtitle),
                        action: onMultiplayer
                    )
                }
                .padding(.horizontal, 24)

                Spacer()
            }

            PillIconButton(systemImage: "gearshape.fill", action: onSettings)
                .padding(.top, 12)
                .padding(.trailing, 20)
                .accessibilityLabel(lang.tr(.settingsTitle))
        }
    }
}

private struct ModeCard<Icon: View>: View {
    @ViewBuilder let icon: () -> Icon
    let iconBg: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(iconBg)
                        .frame(width: 46, height: 46)
                    icon()
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(KG.F.cardTitle)
                        .tracking(-0.3)
                        .foregroundStyle(KG.C.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(hex: 0x7A7A72))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(KG.C.chevron)
            }
            .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18))
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(KG.C.card)
            )
            .kgCardShadow()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Icons

private struct LearnIcon: View {
    var body: some View {
        ZStack {
            Image(systemName: "book.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [KG.C.blue, KG.C.blueLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

private struct ChallengeIcon: View {
    var body: some View {
        Image(systemName: "person.2.fill")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(
                LinearGradient(
                    colors: [KG.C.orange, KG.C.orangeLite],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

#Preview {
    ContentView()
        .environment(LanguageStore())
        .environment(PreferencesStore())
}
