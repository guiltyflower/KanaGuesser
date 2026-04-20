import SwiftUI

struct LearnView: View {
    let scripts: Set<Script>
    let onExit: () -> Void

    static let roundSize = 10

    private enum Phase {
        case initial
        case retry(initialCorrect: Int)
        case finished(initialCorrect: Int, retry: RetrySummary?)
    }

    struct RetrySummary {
        let total: Int
        let stillWrong: Int
    }

    @State private var sequence: [Kana]
    @State private var phase: Phase = .initial
    @State private var roundID = UUID()

    init(scripts: Set<Script>, onExit: @escaping () -> Void) {
        self.scripts = scripts
        self.onExit = onExit
        _sequence = State(initialValue: KanaSequenceBuilder.make(scripts: scripts, count: Self.roundSize))
    }

    var body: some View {
        switch phase {
        case .initial:
            GameRoundView(
                kanaSequence: sequence,
                playerLabel: nil,
                onExit: onExit
            ) { correct, wrongs in
                handleInitialFinish(correct: correct, wrongs: wrongs)
            }
            .id(roundID)

        case .retry:
            GameRoundView(
                kanaSequence: sequence,
                playerLabel: "Ripasso",
                onExit: onExit
            ) { _, wrongs in
                handleRetryFinish(wrongs: wrongs)
            }
            .id(roundID)

        case .finished(let initialCorrect, let retry):
            ResultsView(
                correct: initialCorrect,
                total: Self.roundSize,
                retry: retry,
                onNewRound: startNewRound,
                onExit: onExit
            )
            .padding(24)
        }
    }

    private func handleInitialFinish(correct: Int, wrongs: [Kana]) {
        if wrongs.isEmpty {
            withAnimation(.spring(response: 0.4)) {
                phase = .finished(initialCorrect: correct, retry: nil)
            }
        } else {
            sequence = wrongs.shuffled()
            roundID = UUID()
            withAnimation(.easeInOut(duration: 0.25)) {
                phase = .retry(initialCorrect: correct)
            }
        }
    }

    private func handleRetryFinish(wrongs: [Kana]) {
        guard case .retry(let initialCorrect) = phase else { return }
        let summary = RetrySummary(total: sequence.count, stillWrong: wrongs.count)
        withAnimation(.spring(response: 0.4)) {
            phase = .finished(initialCorrect: initialCorrect, retry: summary)
        }
    }

    private func startNewRound() {
        sequence = KanaSequenceBuilder.make(scripts: scripts, count: Self.roundSize)
        roundID = UUID()
        phase = .initial
    }
}

struct ResultsView: View {
    let correct: Int
    let total: Int
    let retry: LearnView.RetrySummary?
    let onNewRound: () -> Void
    let onExit: () -> Void

    var body: some View {
        let percent = total > 0 ? Int(Double(correct) / Double(total) * 100) : 0
        let (emoji, title) = resultCopy(for: correct, total: total)
        return VStack(spacing: 24) {
            Spacer()
            Text(emoji).font(.system(size: 96))
            Text(title).font(.largeTitle.bold())
            Text("\(correct) / \(total)  •  \(percent)%")
                .font(.title2.monospacedDigit())
                .foregroundStyle(.secondary)

            if let retry {
                retryCard(retry)
                    .padding(.horizontal, 16)
            }

            VStack(spacing: 12) {
                Button(action: onNewRound) {
                    Label("Nuovo round", systemImage: "arrow.clockwise")
                        .font(.title3.bold())
                        .frame(maxWidth: 320)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(action: onExit) {
                    Label("Menu", systemImage: "house")
                        .font(.headline)
                        .frame(maxWidth: 320)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func retryCard(_ retry: LearnView.RetrySummary) -> some View {
        let recovered = retry.total - retry.stillWrong
        return VStack(spacing: 6) {
            Text("Ripasso")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("\(recovered) / \(retry.total) recuperati")
                .font(.headline.monospacedDigit())
            if retry.stillWrong > 0 {
                Text("Ancora \(retry.stillWrong) da rivedere")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
    }

    private func resultCopy(for score: Int, total: Int) -> (String, String) {
        switch score {
        case total: return ("🎉", "Perfetto!")
        case (total - 2)...: return ("🔥", "Ottimo!")
        case (total / 2)...: return ("👍", "Bene")
        default: return ("💪", "Continua ad allenarti")
        }
    }
}
