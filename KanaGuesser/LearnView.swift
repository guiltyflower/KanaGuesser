import SwiftUI

struct LearnView: View {
    let scripts: Set<Script>
    let onExit: () -> Void

    static let roundSize = 10
    static let retryRepeats = 3

    private enum Phase {
        case initial
        case retryReady(initialCorrect: Int, wrongs: [Kana])
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

    @Environment(LanguageStore.self) private var lang

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
            ) { correct, outcomes in
                handleInitialFinish(correct: correct, outcomes: outcomes)
            }
            .id(roundID)

        case .retryReady(let initialCorrect, let wrongs):
            RetryReadyView(
                initialCorrect: initialCorrect,
                total: Self.roundSize,
                wrongCount: wrongs.count,
                onExit: onExit,
                onStart: { beginRetry(initialCorrect: initialCorrect, wrongs: wrongs) }
            )
            .padding(24)

        case .retry:
            GameRoundView(
                kanaSequence: sequence,
                playerLabel: lang.tr(.gameReview),
                onExit: onExit
            ) { _, outcomes in
                handleRetryFinish(outcomes: outcomes)
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

    private func handleInitialFinish(correct: Int, outcomes: [Bool]) {
        let wrongs: [Kana] = zip(sequence, outcomes).compactMap { $0.1 ? nil : $0.0 }
        if wrongs.isEmpty {
            withAnimation(.spring(response: 0.4)) {
                phase = .finished(initialCorrect: correct, retry: nil)
            }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                phase = .retryReady(initialCorrect: correct, wrongs: wrongs)
            }
        }
    }

    private func beginRetry(initialCorrect: Int, wrongs: [Kana]) {
        // Ripassiamo ogni kana sbagliato `retryRepeats` volte: N passate indipendentemente
        // mescolate, concatenate. Se due passate confinano con lo stesso kana, scambiamo
        // il primo elemento della seconda con il successivo per evitare doppioni immediati.
        var passes = (0..<Self.retryRepeats).map { _ in wrongs.shuffled() }
        var result: [Kana] = []
        for p in passes.indices {
            if let last = result.last,
               passes[p].count >= 2,
               passes[p][0] == last {
                passes[p].swapAt(0, 1)
            }
            result.append(contentsOf: passes[p])
        }
        sequence = result
        roundID = UUID()
        withAnimation(.easeInOut(duration: 0.25)) {
            phase = .retry(initialCorrect: initialCorrect)
        }
    }

    private func handleRetryFinish(outcomes: [Bool]) {
        guard case .retry(let initialCorrect) = phase else { return }

        // Raggruppa gli esiti per kana, nell'ordine in cui sono apparsi nella sequenza.
        var perKana: [Kana: [Bool]] = [:]
        for (k, ok) in zip(sequence, outcomes) {
            perKana[k, default: []].append(ok)
        }

        // Un kana è recuperato se: almeno 2 corretti su 3 E l'ultima risposta è giusta.
        let uniqueCount = perKana.count
        let recovered = perKana.values.filter(Self.isRecovered).count

        let summary = RetrySummary(total: uniqueCount, stillWrong: uniqueCount - recovered)
        withAnimation(.spring(response: 0.4)) {
            phase = .finished(initialCorrect: initialCorrect, retry: summary)
        }
    }

    private static func isRecovered(_ outcomes: [Bool]) -> Bool {
        guard outcomes.last == true else { return false }
        return outcomes.filter { $0 }.count >= 2
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

    @Environment(LanguageStore.self) private var lang

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
                    Label(lang.tr(.resultNewRound), systemImage: "arrow.clockwise")
                        .font(.title3.bold())
                        .frame(maxWidth: 320)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(action: onExit) {
                    Label(lang.tr(.resultMenu), systemImage: "house")
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
            Text(lang.tr(.resultReviewHeading))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(lang.tr(.resultReviewRecovered, recovered, retry.total))
                .font(.headline.monospacedDigit())
            if retry.stillWrong > 0 {
                Text(lang.tr(.resultReviewStill, retry.stillWrong))
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
        case total: return ("🎉", lang.tr(.resultPerfect))
        case (total - 2)...: return ("🔥", lang.tr(.resultGreat))
        case (total / 2)...: return ("👍", lang.tr(.resultGood))
        default: return ("💪", lang.tr(.resultKeepGoing))
        }
    }
}

private struct RetryReadyView: View {
    let initialCorrect: Int
    let total: Int
    let wrongCount: Int
    let onExit: () -> Void
    let onStart: () -> Void

    @Environment(LanguageStore.self) private var lang

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 20) {
                Spacer()

                Text("📝").font(.system(size: 72))
                Text(lang.tr(.resultReviewHeading))
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.accentColor)

                VStack(spacing: 6) {
                    Text(lang.tr(.retryReadyScore, initialCorrect, total))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(lang.tr(.retryReadyCount, wrongCount))
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)

                Button(action: onStart) {
                    Label(lang.tr(.retryReadyStart), systemImage: "play.fill")
                        .font(.title3.bold())
                        .frame(maxWidth: 320)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 8)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )

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
}
