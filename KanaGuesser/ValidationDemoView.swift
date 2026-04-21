import SwiftUI
import PencilKit

/// Minimal playground view: draw a character, tap "Verifica", see shape/order/direction feedback.
/// Keep this separate from the main game for now — wire it into the menu when you're happy with tuning.
struct ValidationDemoView: View {
    let template: KanaTemplate
    var config: ValidationConfig = .default

    @State private var drawing = PKDrawing()
    @State private var result: ValidationResult?

    @Environment(LanguageStore.self) private var lang

    var body: some View {
        VStack(spacing: 16) {
            header

            canvas
                .frame(maxHeight: .infinity)

            actionRow

            if let result {
                resultCard(result)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(20)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: result)
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 4) {
            Text(lang.tr(.valWrite))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\"\(template.romaji)\"")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
            Text(lang.tr(.valStrokesCount, template.strokeCount))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var canvas: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.separator), lineWidth: 1)
            DrawingCanvas(drawing: $drawing)
                .padding(16)
        }
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button {
                drawing = PKDrawing()
                result = nil
            } label: {
                Label(lang.tr(.gameClear), systemImage: "eraser")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                result = KanaValidator.validate(
                    pkStrokes: drawing.strokes,
                    template: template,
                    config: config
                )
            } label: {
                Label(lang.tr(.valCheck), systemImage: "checkmark.seal")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(drawing.strokes.isEmpty)
        }
        .controlSize(.large)
    }

    @ViewBuilder
    private func resultCard(_ r: ValidationResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if case let .strokeCountMismatch(exp, act) = r.failure {
                Label(lang.tr(.valWrongStrokes, act, exp),
                      systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            } else if case .emptyInput = r.failure {
                Label(lang.tr(.valEmpty), systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            } else {
                summaryRow(lang.tr(.valShape), ok: r.shapeCorrect)
                summaryRow(lang.tr(.valOrder), ok: r.orderCorrect)
                summaryRow(lang.tr(.valDirection), ok: r.directionCorrect)

                if !r.orderCorrect || !r.directionCorrect || !r.shapeCorrect {
                    Divider()
                    strokeBreakdown(r)
                }

                Text(lang.tr(.valAvgDistance, r.averageDistance))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func summaryRow(_ label: String, ok: Bool) -> some View {
        HStack {
            Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(ok ? .green : .red)
            Text(label).font(.subheadline.weight(.medium))
            Spacer()
        }
    }

    private func strokeBreakdown(_ r: ValidationResult) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(r.strokeDetails.enumerated()), id: \.offset) { idx, d in
                HStack(spacing: 8) {
                    Text(lang.tr(.valStroke, idx + 1))
                        .font(.footnote.monospacedDigit())
                        .frame(width: 80, alignment: .leading)

                    if d.matchedTemplateIndex != idx {
                        Text(lang.tr(.valWasStroke, d.matchedTemplateIndex + 1))
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                    if !d.directionOk {
                        Text(lang.tr(.valReversed))
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                    Spacer()
                    Text(String(format: "%.3f", d.distance))
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(d.shapeOk ? .green : .red)
                }
            }
        }
    }
}

#Preview {
    let fakeTemplate = KanaTemplate(
        character: "|",
        romaji: "stub",
        strokes: [
            StrokeTemplate(points: [CGPoint(x: 0.5, y: 0.05), CGPoint(x: 0.5, y: 0.95)])
        ]
    )
    return ValidationDemoView(template: fakeTemplate)
        .environment(LanguageStore())
}
