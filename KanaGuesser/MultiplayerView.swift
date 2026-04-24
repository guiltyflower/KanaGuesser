import SwiftUI

struct MultiplayerView: View {
    let scripts: Set<Script>
    let onExit: () -> Void

    static let roundSize = 10

    private enum Phase {
        case ready(player: Int, previousScore: Int?)
        case playing(player: Int, player1Score: Int?)
        case finished(player1: Int, player2: Int)
    }

    @State private var phase: Phase = .ready(player: 1, previousScore: nil)
    @State private var sequence: [Kana]
    @State private var roundID = UUID()

    @Environment(LanguageStore.self) private var lang

    init(scripts: Set<Script>, onExit: @escaping () -> Void) {
        self.scripts = scripts
        self.onExit = onExit
        _sequence = State(initialValue: KanaSequenceBuilder.make(scripts: scripts, count: Self.roundSize))
    }

    var body: some View {
        switch phase {
        case .ready(let player, let previousScore):
            MultiplayerReadyView(
                player: player,
                previousScore: previousScore,
                total: Self.roundSize,
                onExit: onExit,
                onStart: {
                    sequence = KanaSequenceBuilder.make(scripts: scripts, count: Self.roundSize)
                    roundID = UUID()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        phase = .playing(
                            player: player,
                            player1Score: player == 2 ? previousScore : nil
                        )
                    }
                }
            )

        case .playing(let player, let p1Score):
            GameRoundView(
                kanaSequence: sequence,
                playerLabel: lang.tr(.mpPlayer, player),
                onExit: onExit
            ) { score, _ in
                withAnimation(.spring(response: 0.4)) {
                    if player == 1 {
                        phase = .ready(player: 2, previousScore: score)
                    } else {
                        phase = .finished(player1: p1Score ?? 0, player2: score)
                    }
                }
            }
            .id(roundID)

        case .finished(let p1, let p2):
            ChallengeFinalView(
                player1Score: p1,
                player2Score: p2,
                total: Self.roundSize,
                onRematch: startRematch,
                onExit: onExit
            )
        }
    }

    private func startRematch() {
        sequence = KanaSequenceBuilder.make(scripts: scripts, count: Self.roundSize)
        roundID = UUID()
        phase = .ready(player: 1, previousScore: nil)
    }
}

// MARK: - Pass / Ready screen (between players or intro)

private struct MultiplayerReadyView: View {
    let player: Int
    let previousScore: Int?
    let total: Int
    let onExit: () -> Void
    let onStart: () -> Void

    @Environment(LanguageStore.self) private var lang

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                Spacer()
                card
                    .padding(.horizontal, 24)
                    .frame(maxWidth: 400)
                Spacer()
            }

            PillIconButton(systemImage: "xmark", size: 36, iconSize: 13, action: onExit)
                .padding(.leading, 16)
                .padding(.top, 12)
        }
    }

    @ViewBuilder
    private var card: some View {
        VStack(spacing: 0) {
            KGLabel(text: previousScore == nil ? lang.tr(.mpStart) : lang.tr(.mpTurnEnded))
                .padding(.top, 32)

            Text(titleText)
                .font(KG.F.section)
                .tracking(-0.8)
                .foregroundStyle(KG.C.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 6)

            passBox
                .padding(.horizontal, 24)
                .padding(.top, 22)

            KGButton(variant: .primary, action: onStart) {
                Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .bold))
                Text(ctaText)
            }
            .padding(.horizontal, 24)
            .padding(.top, 22)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(KG.C.card)
        )
        .kgCardShadow(lifted: true)
    }

    private var titleText: String {
        guard let previousScore else {
            return lang.tr(.mpIntro, total)
        }
        return "\(lang.tr(.mpPlayer, 1)): \(previousScore)/\(total)"
    }

    @ViewBuilder
    private var passBox: some View {
        if previousScore != nil {
            VStack(spacing: 4) {
                Text(lang.tr(.mpPassDevice))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(KG.C.textSecondary)
                Text(lang.tr(.mpPlayer, player))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .tracking(-0.4)
                    .foregroundStyle(KG.C.orange)
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16))
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(KG.C.bgCream)
            )
        } else {
            EmptyView()
        }
    }

    private var ctaText: String {
        if previousScore == nil {
            return lang.tr(.mpStart)
        }
        return lang.tr(.mpStartTurn, string: lang.tr(.mpPlayer, player))
    }
}

// MARK: - Challenge final

private struct ChallengeFinalView: View {
    let player1Score: Int
    let player2Score: Int
    let total: Int
    let onRematch: () -> Void
    let onExit: () -> Void

    @Environment(LanguageStore.self) private var lang

    private var winner: Int {
        if player1Score == player2Score { return 0 }
        return player1Score > player2Score ? 1 : 2
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack(spacing: 30) {
                    header
                    HStack(spacing: 10) {
                        PlayerScoreCard(
                            player: 1,
                            score: player1Score,
                            total: total,
                            isWinner: winner == 1
                        )
                        PlayerScoreCard(
                            player: 2,
                            score: player2Score,
                            total: total,
                            isWinner: winner == 2
                        )
                    }
                    VStack(spacing: 10) {
                        KGButton(variant: .primary, action: onRematch) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .bold))
                            Text(lang.tr(.mpRematch))
                        }
                        KGButton(variant: .secondary, action: onExit) {
                            Text(lang.tr(.resultMenu))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 100)
                .padding(.bottom, 40)
            }

            PillIconButton(systemImage: "xmark", size: 36, iconSize: 13, action: onExit)
                .padding(.leading, 16)
                .padding(.top, 12)
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            KGLabel(text: lang.tr(.mpChallengeDone))
            Text(winnerText)
                .font(.system(size: 42, weight: .black, design: .rounded))
                .tracking(-1.2)
                .foregroundStyle(KG.C.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }

    private var winnerText: String {
        if winner == 0 { return lang.tr(.mpTie) }
        return lang.tr(.mpWinner, winner)
    }
}

private struct PlayerScoreCard: View {
    let player: Int
    let score: Int
    let total: Int
    let isWinner: Bool

    @Environment(LanguageStore.self) private var lang

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                KGLabel(text: lang.tr(.mpPlayer, player))
                    .padding(.top, 18)
                Text("\(score)")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .tracking(-1)
                    .foregroundStyle(KG.C.textPrimary)
                    .padding(.top, 6)
                Text("/ \(total)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(KG.C.textTertiary)
                    .padding(.top, 2)
                    .padding(.bottom, 18)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(KG.C.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isWinner ? KG.C.orange : .clear, lineWidth: 2)
            )
            .shadow(
                color: isWinner ? KG.C.orange.opacity(0.3) : Color.black.opacity(0.08),
                radius: isWinner ? 16 : 8,
                x: 0, y: isWinner ? 4 : 2
            )

            if isWinner {
                Text(lang.tr(.mpWinnerBadge))
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(0.6)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(KG.C.orange))
                    .offset(y: -10)
            }
        }
    }
}
