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
        VStack(spacing: 18) {
            topBar
            progressSegments
            promptCard
            Spacer(minLength: 0)
            bottomArea
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 32)
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            PillIconButton(systemImage: "xmark", size: 36, iconSize: 13, action: onExit)

            VStack(spacing: 2) {
                KGLabel(text: headerLabel, color: Color(hex: 0x7A7468))
                HStack(spacing: 4) {
                    Text("\(index + 1)")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .tracking(-0.4)
                        .foregroundStyle(KG.C.textPrimary)
                    Text("/ \(total)")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(KG.C.textMuted)
                }
            }
            .frame(maxWidth: .infinity)

            Color.clear.frame(width: 36, height: 36)
        }
    }

    private var headerLabel: String {
        playerLabel ?? "KanaGuesser"
    }

    // MARK: - Progress segments

    private var progressSegments: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(segmentColor(at: i))
                    .frame(height: 6)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: outcomes.count)
    }

    private func segmentColor(at i: Int) -> Color {
        if i < outcomes.count {
            return outcomes[i] ? KG.C.successSoft : KG.C.danger
        }
        if i == index { return KG.C.textPrimary.opacity(0.35) }
        return KG.C.textPrimary.opacity(0.12)
    }

    // MARK: - Prompt card

    private var promptCard: some View {
        VStack(spacing: 8) {
            KGLabel(text: lang.tr(.gameDrawChar))
            Text(current.romaji)
                .font(KG.F.romaji)
                .tracking(-2)
                .foregroundStyle(KG.C.textPrimary)
            Text(current.script.label)
                .font(KG.F.caption)
                .foregroundStyle(KG.C.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 22, trailing: 20))
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(KG.C.card)
        )
        .kgCardShadow(lifted: true)
    }

    // MARK: - Bottom (draw or reveal)

    private var bottomArea: some View {
        VStack(spacing: 14) {
            if !revealed {
                drawPanel
                drawButtons
            } else {
                revealPanel
                revealButtons
            }
        }
    }

    private var drawPanel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(KG.C.card)
                .kgCardShadow(lifted: true)

            // Dashed guide cross
            GeometryReader { g in
                Path { path in
                    path.move(to: CGPoint(x: g.size.width / 2, y: 12))
                    path.addLine(to: CGPoint(x: g.size.width / 2, y: g.size.height - 12))
                    path.move(to: CGPoint(x: 12, y: g.size.height / 2))
                    path.addLine(to: CGPoint(x: g.size.width - 12, y: g.size.height / 2))
                }
                .stroke(KG.C.guideLine,
                        style: StrokeStyle(lineWidth: 1, dash: [4, 6]))
            }
            .allowsHitTesting(false)

            DrawingCanvas(drawing: $drawing)
                .padding(12)
                .id(index)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 340)
    }

    private var drawButtons: some View {
        HStack(spacing: 10) {
            KGButton(variant: .secondary, disabled: drawing.strokes.isEmpty) {
                drawing = PKDrawing()
            } content: {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .semibold))
                Text(lang.tr(.gameClear))
            }

            KGButton(variant: .primary, disabled: drawing.strokes.isEmpty) {
                withAnimation(.spring(response: 0.35)) { revealed = true }
            } content: {
                Image(systemName: "eye")
                    .font(.system(size: 15, weight: .semibold))
                Text(lang.tr(.gameShowAnswer))
            }
        }
        .frame(maxWidth: 340)
    }

    private var revealPanel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(KG.C.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                )
                .kgCardShadow(lifted: true)

            VStack(spacing: 0) {
                KGLabel(text: lang.tr(.gameAnswer))
                    .padding(.top, 14)
                Spacer(minLength: 0)
                Text(current.character)
                    .font(KG.F.kanaDisplay(size: 180))
                    .foregroundStyle(KG.C.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Spacer(minLength: 0)
                Text(current.romaji)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(KG.C.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(KG.C.bgCream)
                    )
                    .padding(.bottom, 16)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 340)
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }

    private var revealButtons: some View {
        HStack(spacing: 10) {
            KGButton(variant: .danger) {
                grade(correct: false)
            } content: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                Text(lang.tr(.gameWrong))
            }

            KGButton(variant: .success) {
                grade(correct: true)
            } content: {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                Text(lang.tr(.gameRight))
            }
        }
        .frame(maxWidth: 340)
    }

    private func grade(correct wasCorrect: Bool) {
        outcomes.append(wasCorrect)
        if wasCorrect { correct += 1 }
        drawing = PKDrawing()
        if index + 1 >= total {
            onFinished(correct, outcomes)
        } else {
            withAnimation(.easeInOut(duration: 0.22)) {
                index += 1
                revealed = false
            }
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
