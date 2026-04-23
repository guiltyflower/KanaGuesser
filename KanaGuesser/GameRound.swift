import SwiftUI
import PencilKit

struct GameRoundView: View {
    let kanaSequence: [Kana]
    let playerLabel: String?
    let onExit: () -> Void
    /// `outcomes[i]` è `true` se l'utente ha risposto correttamente alla i-esima domanda
    /// della `kanaSequence`. Il caller può così dedurre i kana sbagliati e calcolare
    /// statistiche per-kana (es. regole di recupero nel ripasso).
    let onFinished: (_ correct: Int, _ outcomes: [Bool]) -> Void

    @State private var index = 0
    @State private var drawing = PKDrawing()
    @State private var revealed = false
    @State private var correct = 0
    @State private var outcomes: [Bool] = []

    @Environment(LanguageStore.self) private var lang

    private var current: Kana { kanaSequence[index] }
    private var total: Int { kanaSequence.count }

    var body: some View {
        GeometryReader { geo in
            let isWide = geo.size.width > geo.size.height
            Group {
                if isWide {
                    HStack(spacing: 24) {
                        promptPane.frame(maxWidth: 360)
                        canvasPane
                    }
                } else {
                    VStack(spacing: 20) {
                        promptPane
                        canvasPane
                    }
                }
            }
            .padding(24)
        }
    }

    private var promptPane: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            VStack(alignment: .leading, spacing: 12) {
                Text(lang.tr(.gameDrawThe))
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text(current.script.rawValue)
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(current.script == .hiragana ? Color.pink : Color.blue)
                Text(lang.tr(.gameConnector))
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("\"\(current.romaji)\"")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )

            if revealed {
                revealCard
                    .transition(.scale.combined(with: .opacity))
            }

            Spacer(minLength: 0)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Button(action: onExit) {
                    Image(systemName: "xmark")
                        .font(.subheadline.weight(.bold))
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color(.tertiarySystemFill)))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)

                if let playerLabel {
                    Text(playerLabel)
                        .font(.title2.bold())
                } else {
                    Text("KanaGuesser")
                        .font(.title2.bold())
                }
                Spacer()
                Text("\(index + 1) / \(total)")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            progressBar
            Text(lang.tr(.gameCorrectCount, correct))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var progressBar: some View {
        HStack(spacing: 3) {
            ForEach(0..<total, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(segmentColor(at: i))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 8)
    }

    private func segmentColor(at i: Int) -> Color {
        if i < outcomes.count {
            return outcomes[i] ? .green : .red
        }
        return Color(.tertiarySystemFill)
    }

    private var revealCard: some View {
        VStack(spacing: 12) {
            Text(lang.tr(.gameAnswer))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(current.character)
                .font(.system(size: 140, weight: .regular))
            HStack(spacing: 12) {
                Button {
                    grade(correct: false)
                } label: {
                    Label(lang.tr(.gameWrong), systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)

                Button {
                    grade(correct: true)
                } label: {
                    Label(lang.tr(.gameRight), systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .controlSize(.large)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var canvasPane: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 1)

                GeometryReader { g in
                    Path { path in
                        path.move(to: CGPoint(x: g.size.width / 2, y: 0))
                        path.addLine(to: CGPoint(x: g.size.width / 2, y: g.size.height))
                        path.move(to: CGPoint(x: 0, y: g.size.height / 2))
                        path.addLine(to: CGPoint(x: g.size.width, y: g.size.height / 2))
                    }
                    .stroke(Color(.separator).opacity(0.5),
                            style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
                }
                .padding(16)

                DrawingCanvas(drawing: $drawing)
                    .padding(16)
                    .id(index)
            }

            HStack(spacing: 12) {
                Button {
                    drawing = PKDrawing()
                } label: {
                    Label(lang.tr(.gameClear), systemImage: "eraser")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                if !revealed {
                    Button {
                        withAnimation(.spring(response: 0.35)) { revealed = true }
                    } label: {
                        Label(lang.tr(.gameShowAnswer), systemImage: "eye")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .controlSize(.large)
        }
    }

    private func grade(correct wasCorrect: Bool) {
        outcomes.append(wasCorrect)
        if wasCorrect { correct += 1 }
        drawing = PKDrawing()
        revealed = false
        if index + 1 >= total {
            onFinished(correct, outcomes)
        } else {
            index += 1
        }
    }
}

enum KanaSequenceBuilder {
    static func make(scripts: Set<Script>, count: Int) -> [Kana] {
        let pool = KanaDatabase.all(for: scripts)
        guard !pool.isEmpty else { return [] }
        var result: [Kana] = []
        var last: Kana?
        for _ in 0..<count {
            let candidates = pool.filter { $0 != last }
            let pick = (candidates.isEmpty ? pool : candidates).randomElement()!
            result.append(pick)
            last = pick
        }
        return result
    }
}
