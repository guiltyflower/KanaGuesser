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

    init(scripts: Set<Script>, onExit: @escaping () -> Void) {
        self.scripts = scripts
        self.onExit = onExit
        _sequence = State(initialValue: KanaSequenceBuilder.make(scripts: scripts, count: Self.roundSize))
    }

    var body: some View {
        switch phase {
        case .ready(let player, let previousScore):
            ReadyView(
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
            .padding(24)

        case .playing(let player, let p1Score):
            GameRoundView(
                kanaSequence: sequence,
                playerLabel: "Giocatore \(player)",
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
            MultiplayerResultsView(
                player1Score: p1,
                player2Score: p2,
                total: Self.roundSize,
                onRematch: startRematch,
                onExit: onExit
            )
            .padding(24)
        }
    }

    private func startRematch() {
        sequence = KanaSequenceBuilder.make(scripts: scripts, count: Self.roundSize)
        roundID = UUID()
        phase = .ready(player: 1, previousScore: nil)
    }
}

private struct ReadyView: View {
    let player: Int
    let previousScore: Int?
    let total: Int
    let onExit: () -> Void
    let onStart: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 20) {
                Spacer()

                Text("Tocca al")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("Giocatore \(player)")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(player == 1 ? Color.pink : Color.blue)

                if let previousScore {
                    VStack(spacing: 6) {
                        Text("Giocatore 1 ha fatto")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("\(previousScore) / \(total)")
                            .font(.title.monospacedDigit().bold())
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
                    .padding(.horizontal, 8)
                } else {
                    Text("Disegnerai \(total) kana. Poi toccherà al Giocatore 2.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Button(action: onStart) {
                    Label(player == 1 ? "Inizia" : "Avanti", systemImage: "play.fill")
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

private struct MultiplayerResultsView: View {
    let player1Score: Int
    let player2Score: Int
    let total: Int
    let onRematch: () -> Void
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text(headline)
                .font(.system(size: 72))
            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                scoreCard(
                    name: "Giocatore 1",
                    score: player1Score,
                    tint: .pink,
                    highlight: player1Score > player2Score
                )
                scoreCard(
                    name: "Giocatore 2",
                    score: player2Score,
                    tint: .blue,
                    highlight: player2Score > player1Score
                )
            }
            .padding(.horizontal, 8)

            VStack(spacing: 12) {
                Button(action: onRematch) {
                    Label("Rivincita", systemImage: "arrow.clockwise")
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

    private var headline: String {
        if player1Score == player2Score { return "🤝" }
        return "🏆"
    }

    private var title: String {
        if player1Score == player2Score { return "Pareggio!" }
        return player1Score > player2Score ? "Vince il Giocatore 1" : "Vince il Giocatore 2"
    }

    private func scoreCard(name: String, score: Int, tint: Color, highlight: Bool) -> some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
            Text("\(score)")
                .font(.system(size: 48, weight: .heavy, design: .rounded).monospacedDigit())
            Text("su \(total)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(highlight ? tint : .clear, lineWidth: 2)
        )
    }
}
