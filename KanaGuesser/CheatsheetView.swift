import SwiftUI

struct CheatsheetView: View {
    let scripts: Set<Script>
    let onExit: () -> Void

    @Environment(LanguageStore.self) private var lang
    @State private var focused: Kana?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

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
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(kanas) { kana in
                    Button {
                        focused = kana
                    } label: {
                        cell(for: kana)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
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
