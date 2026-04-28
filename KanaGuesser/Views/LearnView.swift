import SwiftUI

struct LearnView: View {
    let scripts: Set<Script>
    let rounds: Int
    let recoveryPasses: Int
    let onExit: () -> Void

    private enum Phase {
        case initial
        case retryReady(initialCorrect: Int, wrongs: [Kana], results: [TurnResult])
        case retry(initialCorrect: Int)
        case finished(initialCorrect: Int, retry: RetrySummary?, results: [TurnResult])
    }

    struct RetrySummary {
        let total: Int
        let stillWrong: Int
    }

    struct TurnResult: Identifiable {
        let id = UUID()
        let kana: Kana
        let correct: Bool
    }

    @State private var sequence: [Kana]
    @State private var phase: Phase = .initial
    @State private var roundID = UUID()

    @Environment(LanguageStore.self) private var lang
    @Environment(StatsStore.self) private var stats

    init(scripts: Set<Script>, rounds: Int, recoveryPasses: Int, onExit: @escaping () -> Void) {
        self.scripts = scripts
        self.rounds = rounds
        self.recoveryPasses = recoveryPasses
        self.onExit = onExit
        _sequence = State(initialValue: KanaSequenceBuilder.make(scripts: scripts, count: rounds))
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

        case .retryReady(let initialCorrect, let wrongs, let results):
            ResultsView(
                phase: .roundCompleted(wrongCount: wrongs.count),
                correct: initialCorrect,
                total: rounds,
                results: results,
                primaryTitle: lang.tr(.retryReadyStart),
                onPrimary: { beginRetry(initialCorrect: initialCorrect, wrongs: wrongs) },
                onExit: onExit
            )

        case .retry:
            GameRoundView(
                kanaSequence: sequence,
                playerLabel: lang.tr(.gameReview),
                onExit: onExit
            ) { _, outcomes in
                handleRetryFinish(outcomes: outcomes)
            }
            .id(roundID)

        case .finished(let initialCorrect, let retry, let results):
            ResultsView(
                phase: .trainingDone(retry: retry),
                correct: initialCorrect,
                total: rounds,
                results: results,
                primaryTitle: lang.tr(.resultNewRound),
                onPrimary: startNewRound,
                onExit: onExit
            )
        }
    }

    private func handleInitialFinish(correct: Int, outcomes: [Bool]) {
        stats.record(Array(zip(sequence, outcomes)))
        let results = zip(sequence, outcomes).map { TurnResult(kana: $0.0, correct: $0.1) }
        let wrongs: [Kana] = results.compactMap { $0.correct ? nil : $0.kana }
        if wrongs.isEmpty {
            stats.recordGame(rounds: rounds, correct: correct)
            withAnimation(.spring(response: 0.4)) {
                phase = .finished(initialCorrect: correct, retry: nil, results: results)
            }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                phase = .retryReady(initialCorrect: correct, wrongs: wrongs, results: results)
            }
        }
    }

    private func beginRetry(initialCorrect: Int, wrongs: [Kana]) {
        var passes = (0..<recoveryPasses).map { _ in wrongs.shuffled() }
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

        // Per-kana stats only count the initial pass — retry would over-weight wrongs.

        var perKana: [Kana: [Bool]] = [:]
        for (k, ok) in zip(sequence, outcomes) {
            perKana[k, default: []].append(ok)
        }

        let uniqueCount = perKana.count
        let recovered = perKana.values.filter(Self.isRecovered).count

        // Build per-kana final result list for the summary grid.
        var seen = Set<Kana>()
        let results: [TurnResult] = sequence.compactMap { k in
            guard !seen.contains(k) else { return nil }
            seen.insert(k)
            let ok = Self.isRecovered(perKana[k] ?? [])
            return TurnResult(kana: k, correct: ok)
        }

        let summary = RetrySummary(total: uniqueCount, stillWrong: uniqueCount - recovered)
        stats.recordRetry(wrongs: uniqueCount, recovered: recovered)
        stats.recordGame(rounds: rounds, correct: initialCorrect)
        withAnimation(.spring(response: 0.4)) {
            phase = .finished(initialCorrect: initialCorrect, retry: summary, results: results)
        }
    }

    private static func isRecovered(_ outcomes: [Bool]) -> Bool {
        guard outcomes.last == true else { return false }
        return outcomes.filter { $0 }.count >= 2
    }

    private func startNewRound() {
        sequence = KanaSequenceBuilder.make(scripts: scripts, count: rounds)
        roundID = UUID()
        phase = .initial
    }
}

// MARK: - Results screen

enum ResultsPhase {
    case roundCompleted(wrongCount: Int)
    case trainingDone(retry: LearnView.RetrySummary?)
}

struct ResultsView: View {
    let phase: ResultsPhase
    let correct: Int
    let total: Int
    let results: [LearnView.TurnResult]
    let primaryTitle: String
    let onPrimary: () -> Void
    let onExit: () -> Void

    @Environment(LanguageStore.self) private var lang

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                ScoreRing(correct: correct, total: total)
                if !results.isEmpty {
                    charactersGrid
                }
                ctaStack
            }
            .padding(.horizontal, 24)
            .padding(.top, 100)
            .padding(.bottom, 40)
        }
        .overlay(alignment: .topLeading) {
            PillIconButton(systemImage: "xmark", size: 36, iconSize: 13, action: onExit)
                .padding(.leading, 16)
                .padding(.top, 12)
        }
    }

    @ViewBuilder
    private var header: some View {
        VStack(spacing: 8) {
            KGLabel(text: headerLabel)
            Text(heroText)
                .font(KG.F.heroScore)
                .tracking(-1)
                .foregroundStyle(KG.C.textPrimary)
                .multilineTextAlignment(.center)
            if let sub = subtitle {
                Text(sub)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(KG.C.textSecondary)
            }
        }
    }

    private var headerLabel: String {
        switch phase {
        case .roundCompleted: return lang.tr(.resultRoundCompleted)
        case .trainingDone: return lang.tr(.resultTrainingDone)
        }
    }

    private var heroText: String {
        switch phase {
        case .roundCompleted: return lang.tr(.resultScoreFraction, correct, total)
        case .trainingDone: return lang.tr(.resultGreatJob)
        }
    }

    private var subtitle: String? {
        switch phase {
        case .roundCompleted(let wrongs):
            if wrongs == 0 { return lang.tr(.resultPerfect) }
            return wrongs == 1
                ? lang.tr(.resultReviewOneToGo)
                : lang.tr(.resultReviewManyToGo, wrongs)
        case .trainingDone(let retry):
            guard let retry else { return nil }
            let rec = retry.total - retry.stillWrong
            return lang.tr(.resultReviewRecovered, rec, retry.total)
        }
    }

    private var charactersGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            KGLabel(text: lang.tr(.resultYourCharacters))
                .padding(.horizontal, 6)

            let cols = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
            LazyVGrid(columns: cols, spacing: 8) {
                ForEach(results) { r in
                    CharacterCell(kana: r.kana, correct: r.correct)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(KG.C.card)
        )
        .kgCardShadow()
    }

    private var ctaStack: some View {
        VStack(spacing: 10) {
            KGButton(variant: .primary, action: onPrimary) {
                Text(primaryTitle)
            }
            KGButton(variant: .secondary, action: onExit) {
                Text(lang.tr(.resultMenu))
            }
        }
    }
}

// MARK: - Character cell

struct CharacterCell: View {
    let kana: Kana
    let correct: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 2) {
                Text(kana.character)
                    .font(KG.F.kanaDisplay(size: 28))
                    .foregroundStyle(KG.C.textPrimary)
                Text(kana.romaji)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(KG.C.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(correct ? KG.C.successBg : KG.C.dangerBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(correct ? KG.C.successBrd : KG.C.dangerBrd, lineWidth: 1)
            )

            ZStack {
                Circle()
                    .fill(correct ? KG.C.successSoft : KG.C.danger)
                    .frame(width: 14, height: 14)
                Image(systemName: correct ? "checkmark" : "xmark")
                    .font(.system(size: 7, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .padding(4)
        }
    }
}

// MARK: - Score ring

struct ScoreRing: View {
    let correct: Int
    let total: Int

    @State private var animatedPct: Double = 0

    private var pct: Double {
        total > 0 ? Double(correct) / Double(total) : 0
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(KG.C.ringBg, lineWidth: 12)

            Circle()
                .trim(from: 0, to: animatedPct)
                .stroke(
                    KG.C.successSoft,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(pct * 100))")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .tracking(-1)
                        .foregroundStyle(KG.C.textPrimary)
                    Text("%")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(KG.C.textTertiary)
                }
                Text("\(correct) / \(total)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(KG.C.textTertiary)
            }
        }
        .frame(width: 140, height: 140)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animatedPct = pct
            }
        }
    }
}
