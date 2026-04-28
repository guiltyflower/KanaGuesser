import SwiftUI

struct SettingsView: View {
    @Environment(LanguageStore.self) private var lang
    @Environment(PreferencesStore.self) private var prefs
    @Environment(StatsStore.self) private var stats
    @Environment(\.dismiss) private var dismiss

    @State private var showResetConfirm = false
    @State private var showKanaStats = false

    var body: some View {
        ZStack(alignment: .top) {
            KG.C.bgCreamDark.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                    scriptsSection
                    matchSection
                    statsSection
                    kanaStatsSection
                    languageSection
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .alert(lang.tr(.statsResetConfirm), isPresented: $showResetConfirm) {
            Button(lang.tr(.statsResetCancel), role: .cancel) {}
            Button(lang.tr(.statsReset), role: .destructive) { stats.resetAll() }
        }
        .sheet(isPresented: $showKanaStats) {
            KanaStatsView(scripts: prefs.selectedScripts)
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

    // MARK: - Stats

    private var statsSection: some View {
        SettingsSection(title: lang.tr(.statsHeader)) {
            if stats.totalGames == 0 {
                SettingRow(title: lang.tr(.statsNoData))
            } else {
                SettingRow(
                    title: lang.tr(.statsSummaryTitle),
                    subtitle: lang.tr(
                        .statsSummarySub,
                        stats.totalGames,
                        Int((stats.overallAccuracy * 100).rounded())
                    )
                )
                if let scriptsSub = scriptsAccuracySub() {
                    SettingsDivider()
                    SettingRow(title: lang.tr(.statsScriptsTitle), subtitle: scriptsSub)
                }
                if let last = stats.daily.lastSessionDate {
                    SettingsDivider()
                    let daysSub = lang.tr(.statsDailySub, stats.daily.current, stats.daily.best)
                    let lastSub = lang.tr(.statsDailyLast, string: relativeLastSession(last))
                    SettingRow(
                        title: lang.tr(.statsDailyTitle),
                        subtitle: "\(daysSub) · \(lastSub)"
                    )
                }
                if stats.perfect.best > 0 || stats.perfect.current > 0 {
                    SettingsDivider()
                    SettingRow(
                        title: lang.tr(.statsPerfectTitle),
                        subtitle: lang.tr(.statsPerfectSub, stats.perfect.current, stats.perfect.best)
                    )
                }
                if stats.retry.totalWrongs > 0 {
                    SettingsDivider()
                    SettingRow(
                        title: lang.tr(.statsRecoveryTitle),
                        subtitle: lang.tr(
                            .statsRecoverySub,
                            stats.retry.totalRecovered,
                            stats.retry.totalWrongs,
                            Int((stats.retry.rate * 100).rounded())
                        )
                    )
                }
                ForEach(stats.perMode.keys.sorted(), id: \.self) { rounds in
                    if let m = stats.perMode[rounds] {
                        SettingsDivider()
                        SettingRow(
                            title: lang.tr(.statsModeTitle, rounds),
                            subtitle: lang.tr(
                                .statsModeSub,
                                m.gamesPlayed,
                                m.averageCorrect,
                                m.bestScore
                            )
                        )
                    }
                }
                SettingsDivider()
                Button { showKanaStats = true } label: {
                    HStack(spacing: 12) {
                        Text(lang.tr(.statsKanaButton))
                            .font(KG.F.body)
                            .foregroundStyle(KG.C.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(KG.C.chevron)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .frame(minHeight: 54)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                SettingsDivider()
                Button { showResetConfirm = true } label: {
                    HStack {
                        Text(lang.tr(.statsReset))
                            .font(KG.F.body)
                            .foregroundStyle(KG.C.danger)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .frame(minHeight: 54)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func scriptsAccuracySub() -> String? {
        let h = stats.accuracy(for: .hiragana)
        let k = stats.accuracy(for: .katakana)
        let hPct = Int((h.accuracy * 100).rounded())
        let kPct = Int((k.accuracy * 100).rounded())
        switch (h.seen > 0, k.seen > 0) {
        case (true, true):
            return lang.tr(.statsScriptsSub, hPct, kPct)
        case (true, false):
            return "Hiragana \(hPct)%"
        case (false, true):
            return "Katakana \(kPct)%"
        case (false, false):
            return nil
        }
    }

    private func relativeLastSession(_ date: Date) -> String {
        let cal = Calendar.current
        let diff = cal.dateComponents([.day], from: cal.startOfDay(for: date), to: cal.startOfDay(for: Date())).day ?? 0
        if diff <= 0 { return lang.tr(.statsLastToday) }
        if diff == 1 { return lang.tr(.statsLastYesterday) }
        return lang.tr(.statsLastDaysAgo, diff)
    }

    private var kanaStatsSection: some View {
        let allKanas = KanaDatabase.all(for: prefs.selectedScripts)
        let hardest = stats.sortedByAccuracy(among: allKanas, ascending: true, limit: 5)
        let mastered = stats.sortedByAccuracy(among: allKanas, ascending: false, limit: 5)
        return Group {
            if !hardest.isEmpty || !mastered.isEmpty {
                SettingsSection(title: lang.tr(.statsKanaHeader)) {
                    if !hardest.isEmpty {
                        kanaTopRow(title: lang.tr(.statsHardest), entries: hardest, tint: KG.C.danger)
                    }
                    if !hardest.isEmpty && !mastered.isEmpty {
                        SettingsDivider()
                    }
                    if !mastered.isEmpty {
                        kanaTopRow(title: lang.tr(.statsMastered), entries: mastered, tint: KG.C.success)
                    }
                }
            }
        }
    }

    private func kanaTopRow(title: String, entries: [(Kana, KanaStat)], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(KG.C.textSecondary)
                .padding(.horizontal, 14)
                .padding(.top, 12)
            HStack(spacing: 8) {
                ForEach(Array(entries.enumerated()), id: \.offset) { _, item in
                    let (kana, stat) = item
                    VStack(spacing: 2) {
                        Text(kana.character)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(KG.C.textPrimary)
                        Text(lang.tr(.statsAccuracyShort, Int((stat.accuracy * 100).rounded())))
                            .font(.system(size: 11, weight: .semibold).monospacedDigit())
                            .foregroundStyle(tint)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(KG.C.bgCream)
                    )
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
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
        .environment(StatsStore())
}
