import SwiftUI

struct CheatsheetView: View {
    let scripts: Set<Script>
    let onExit: () -> Void

    @Environment(LanguageStore.self) private var lang
    @State private var focused: Kana?

    /// Gojuon group sizes in display order: a, ka, sa, ta, na, ha, ma, ya, ra, wa, n.
    /// Groups of size 5 form a single row; smaller groups place each character on its own row.
    private static let groupSizes = [5, 5, 5, 5, 5, 5, 5, 3, 5, 2, 1]
    private static let columnCount = 5

    var body: some View {
        ZStack(alignment: .topLeading) {
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
                .padding(.horizontal, 16)
                .padding(.top, 72)
                .padding(.bottom, 24)
            }

            exitButton
        }
        .sheet(item: $focused) { kana in
            KanaDetailSheet(kana: kana)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lang.tr(.cheatsheetTitle))
                .font(.system(size: 34, weight: .heavy, design: .rounded))
            Text(lang.tr(.cheatsheetSubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func section(title: String, kanas: [Kana]) -> some View {
        let rows = Self.gojuonRows(from: kanas)
        return VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
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
            Button {
                focused = kana
            } label: {
                cell(for: kana)
            }
            .buttonStyle(.plain)
        } else {
            Color.clear
                .frame(maxWidth: .infinity)
        }
    }

    /// Place the row's chars centered across the 5 columns. A row of N occupies
    /// columns [start, start+N) where `start = (5 - N) / 2`.
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

    private func cell(for kana: Kana) -> some View {
        VStack(spacing: 2) {
            Text(kana.character)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
            Text(kana.romaji)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black, lineWidth: 1)
        )
    }

    private var exitButton: some View {
        Button(action: onExit) {
            Image(systemName: "xmark")
                .font(.subheadline.weight(.bold))
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color(.tertiarySystemFill)))
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .padding(16)
    }
}

private struct KanaDetailSheet: View {
    let kana: Kana

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(kana.character)
                .font(.system(size: 180, weight: .semibold, design: .rounded))
            Text(kana.romaji)
                .font(.system(size: 36, weight: .bold, design: .rounded).monospaced())
                .foregroundStyle(.secondary)
            Text(kana.script.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CheatsheetView(scripts: [.hiragana, .katakana], onExit: {})
        .environment(LanguageStore())
}
