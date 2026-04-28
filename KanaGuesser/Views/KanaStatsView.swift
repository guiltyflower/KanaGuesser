import SwiftUI

/// Variant of `CheatsheetView` that overlays per-kana stats: each cell is tinted by accuracy
/// (red → yellow → green) and shows the percentage. Reachable from Settings, presented modally.
struct KanaStatsView: View {
    let scripts: Set<Script>

    @Environment(LanguageStore.self) private var lang
    @Environment(StatsStore.self) private var stats
    @Environment(\.dismiss) private var dismiss

    private static let groupSizes = [5, 5, 5, 5, 5, 5, 5, 3, 5, 2, 1]
    private static let columnCount = 5

    var body: some View {
        ZStack(alignment: .topLeading) {
            KG.C.bgCreamDark.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    if scripts.contains(.hiragana) {
                        section(title: Script.hiragana.label, kanas: KanaDatabase.hiragana)
                    }
                    if scripts.contains(.katakana) {
                        section(title: Script.katakana.label, kanas: KanaDatabase.katakana)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 72)
                .padding(.bottom, 24)
            }

            exitButton
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lang.tr(.kanaStatsTitle))
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(KG.C.textPrimary)
            Text(lang.tr(.kanaStatsSubtitle))
                .font(.subheadline)
                .foregroundStyle(KG.C.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func section(title: String, kanas: [Kana]) -> some View {
        let rows = Self.gojuonRows(from: kanas)
        return VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(KG.C.textSecondary)
                .padding(.leading, 4)

            VStack(spacing: 10) {
                ForEach(rows.indices, id: \.self) { i in
                    row(rows[i])
                }
            }
        }
    }

    private func row(_ kanas: [Kana]) -> some View {
        HStack(spacing: 10) {
            ForEach(0..<Self.columnCount, id: \.self) { col in
                slot(at: col, in: kanas)
            }
        }
    }

    @ViewBuilder
    private func slot(at col: Int, in kanas: [Kana]) -> some View {
        if let kana = Self.kana(at: col, in: kanas) {
            cell(for: kana)
        } else {
            Color.clear.frame(maxWidth: .infinity)
        }
    }

    private func cell(for kana: Kana) -> some View {
        let stat = stats.stat(for: kana)
        return VStack(spacing: 2) {
            Text(kana.character)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(KG.C.textPrimary)
            Text(kana.romaji)
                .font(.system(size: 10, weight: .medium).monospaced())
                .foregroundStyle(KG.C.textSecondary)
            accuracyBadge(for: stat)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(backgroundColor(for: stat))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func accuracyBadge(for stat: KanaStat?) -> some View {
        if let stat, stat.seen > 0 {
            VStack(spacing: 0) {
                Text(lang.tr(.statsAccuracyShort, Int((stat.accuracy * 100).rounded())))
                    .font(.system(size: 10, weight: .bold).monospacedDigit())
                    .foregroundStyle(textColor(for: stat))
                Text("\(stat.correct)/\(stat.seen)")
                    .font(.system(size: 9, weight: .medium).monospacedDigit())
                    .foregroundStyle(KG.C.textTertiary)
            }
        } else {
            Text("—")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(KG.C.textTertiary)
        }
    }

    private func backgroundColor(for stat: KanaStat?) -> Color {
        guard let stat, stat.seen > 0 else {
            return KG.C.card
        }
        switch stat.accuracy {
        case ..<0.5:  return KG.C.dangerBg
        case ..<0.75: return Color(hex: 0xFFF1C8)
        default:      return KG.C.successBg
        }
    }

    private func textColor(for stat: KanaStat) -> Color {
        switch stat.accuracy {
        case ..<0.5:  return KG.C.danger
        case ..<0.75: return Color(hex: 0xB47A0E)
        default:      return KG.C.success
        }
    }

    private var exitButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.subheadline.weight(.bold))
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color(.tertiarySystemFill)))
                .foregroundStyle(KG.C.textPrimary)
        }
        .buttonStyle(.plain)
        .padding(16)
    }

    // MARK: - Layout helpers

    private static func kana(at col: Int, in row: [Kana]) -> Kana? {
        let start = (columnCount - row.count) / 2
        let offset = col - start
        guard offset >= 0, offset < row.count else { return nil }
        return row[offset]
    }

    private static func gojuonRows(from kanas: [Kana]) -> [[Kana]] {
        var rows: [[Kana]] = []
        var idx = 0
        for size in groupSizes {
            let end = min(idx + size, kanas.count)
            rows.append(Array(kanas[idx..<end]))
            idx = end
        }
        return rows
    }
}

#Preview {
    KanaStatsView(scripts: [.hiragana, .katakana])
        .environment(LanguageStore())
        .environment(StatsStore())
}
