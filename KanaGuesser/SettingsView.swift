import SwiftUI

struct SettingsView: View {
    @Environment(LanguageStore.self) private var lang
    @Environment(PreferencesStore.self) private var prefs
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            KG.C.bgCreamDark.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                    scriptsSection
                    matchSection
                    languageSection
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text(lang.tr(.settingsTitle))
                .font(KG.F.section)
                .tracking(-0.5)
                .foregroundStyle(KG.C.textPrimary)
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: 0x3A3A3A))
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.black.opacity(0.06)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
    }

    // MARK: - Sections

    private var scriptsSection: some View {
        SettingsSection(title: lang.tr(.settingsScriptsHeader)) {
            SettingRow(
                title: "Hiragana",
                subtitle: "あ い う え お",
                trailing: AnyView(Toggle_(isOn: prefs.selectedScripts.contains(.hiragana)) {
                    prefs.toggle(.hiragana)
                })
            )
            SettingsDivider()
            SettingRow(
                title: "Katakana",
                subtitle: "ア イ ウ エ オ",
                trailing: AnyView(Toggle_(isOn: prefs.selectedScripts.contains(.katakana)) {
                    prefs.toggle(.katakana)
                })
            )
        }
    }

    private var matchSection: some View {
        SettingsSection(title: lang.tr(.settingsMatchHeader)) {
            SettingRow(
                title: lang.tr(.settingsRoundsTitle),
                subtitle: lang.tr(.settingsRoundsSub),
                trailing: AnyView(
                    Stepper_(
                        value: prefs.rounds,
                        min: 5, max: 20, step: 5
                    ) { prefs.rounds = $0 }
                )
            )
            SettingsDivider()
            SettingRow(
                title: lang.tr(.settingsRecoveryTitle),
                subtitle: lang.tr(.settingsRecoverySub),
                trailing: AnyView(
                    Stepper_(
                        value: prefs.recoveryPasses,
                        min: 1, max: 5, step: 1
                    ) { prefs.recoveryPasses = $0 }
                )
            )
        }
    }

    private var preferencesSection: some View {
        SettingsSection(title: lang.tr(.settingsPrefsHeader)) {
            SettingRow(
                title: lang.tr(.settingsSounds),
                subtitle: lang.tr(.settingsSoundsSub),
                trailing: AnyView(Toggle_(isOn: prefs.soundsEnabled) {
                    prefs.soundsEnabled.toggle()
                })
            )
            SettingsDivider()
            SettingRow(
                title: lang.tr(.settingsHaptics),
                subtitle: lang.tr(.settingsHapticsSub),
                trailing: AnyView(Toggle_(isOn: prefs.hapticsEnabled) {
                    prefs.hapticsEnabled.toggle()
                })
            )
        }
    }

    private var languageSection: some View {
        @Bindable var bLang = lang
        return SettingsSection(title: lang.tr(.settingsLanguageHeader)) {
            VStack(spacing: 0) {
                ForEach(Array(Language.allCases.enumerated()), id: \.element) { idx, language in
                    HStack(spacing: 12) {
                        Text(language.flag).font(.system(size: 20))
                        Text(language.nativeName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(KG.C.textPrimary)
                        Spacer()
                        if bLang.current == language {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(KG.C.successSoft)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { bLang.current = language }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)

                    if idx < Language.allCases.count - 1 {
                        SettingsDivider()
                    }
                }
            }
        }
    }
}

// MARK: - Building blocks

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            KGLabel(text: title)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .padding(.top, 6)

            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(KG.C.card)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 1)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
    }
}

private struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(KG.C.divider)
            .frame(height: 1)
            .padding(.leading, 16)
    }
}

private struct SettingRow: View {
    let title: String
    let subtitle: String?
    let trailing: AnyView?

    init(title: String, subtitle: String? = nil, trailing: AnyView? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(KG.F.body)
                    .foregroundStyle(KG.C.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(KG.C.textTertiary)
                }
            }
            Spacer(minLength: 8)
            trailing
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(minHeight: 54)
    }
}

private struct Toggle_: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? KG.C.success : KG.C.toggleOff)
                    .frame(width: 51, height: 31)
                Circle()
                    .fill(Color.white)
                    .frame(width: 27, height: 27)
                    .shadow(color: Color.black.opacity(0.15), radius: 1.5, x: 0, y: 1)
                    .padding(2)
            }
            .animation(.easeInOut(duration: 0.18), value: isOn)
        }
        .buttonStyle(.plain)
    }
}

private struct Stepper_: View {
    let value: Int
    let min: Int
    let max: Int
    let step: Int
    let onChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 2) {
            stepButton(label: "−", enabled: value > min) {
                onChange(Swift.max(min, value - step))
            }
            Text("\(value)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(KG.C.textPrimary)
                .frame(minWidth: 30)
            stepButton(label: "+", enabled: value < max) {
                onChange(Swift.min(max, value + step))
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(KG.C.stepperBg)
        )
    }

    private func stepButton(label: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(KG.C.textPrimary)
                .frame(width: 28, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color.white)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 1, x: 0, y: 1)
                .opacity(enabled ? 1 : 0.35)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

#Preview {
    SettingsView()
        .environment(LanguageStore())
        .environment(PreferencesStore())
}
