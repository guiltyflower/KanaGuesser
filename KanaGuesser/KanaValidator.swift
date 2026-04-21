import Foundation
import CoreGraphics
import PencilKit

// MARK: - Configuration

/// Tunable thresholds. Distances are in normalized [0,1]² space so values
/// are comparable across kana and canvas sizes.
struct ValidationConfig {
    /// Number of equidistant points each stroke is resampled to before comparison.
    /// Higher = more fidelity, more CPU. 32 is a good default.
    var samplePoints: Int = 32

    /// Average per-point Euclidean distance below which a user stroke is considered
    /// to match its template stroke. Range is roughly [0, √2]. Typical good match: ~0.05;
    /// sloppy-but-recognizable: ~0.12; unrelated: >0.25. Tune empirically.
    var shapeThreshold: Double = 0.12

    /// Fraction of strokes that must pass `shapeThreshold` for the overall shape to
    /// be considered correct. 1.0 = strict (every stroke must match).
    var shapeAcceptance: Double = 1.0

    /// If true, direction of each matched stroke is checked against the template.
    var checkDirection: Bool = true

    static let `default` = ValidationConfig()
}

// MARK: - Result types

/// Per-stroke detail describing how a user stroke matched a template stroke.
struct StrokeValidation: Hashable {
    let userIndex: Int               // index of the stroke the user drew (0-based)
    let matchedTemplateIndex: Int    // which template stroke it best matched
    let distance: Double             // average per-point distance (normalized)
    let shapeOk: Bool                // distance <= config.shapeThreshold
    let directionOk: Bool            // user drew start→end in the same direction as template
}

/// Full outcome of validating a set of user strokes against a template.
struct ValidationResult: Hashable {
    enum Failure: Hashable {
        case strokeCountMismatch(expected: Int, actual: Int)
        case emptyInput
    }

    let expectedStrokeCount: Int
    let actualStrokeCount: Int
    let shapeCorrect: Bool           // aggregated from per-stroke `shapeOk` + acceptance fraction
    let orderCorrect: Bool           // true iff optimal matching equals identity permutation
    let directionCorrect: Bool       // true iff every matched stroke drawn in correct direction
    let strokeDetails: [StrokeValidation]
    let failure: Failure?            // non-nil for hard failures (count mismatch, empty input)
    let averageDistance: Double      // mean per-stroke distance; .infinity on hard failure
}

// MARK: - Validator

enum KanaValidator {

    // MARK: Public API

    /// Core validator. Takes raw point arrays so it's easy to unit-test without PencilKit.
    static func validate(
        userStrokes: [[CGPoint]],
        template: KanaTemplate,
        config: ValidationConfig = .default
    ) -> ValidationResult {

        let expected = template.strokeCount
        let actual = userStrokes.count

        guard actual > 0 else {
            return hardFail(.emptyInput, expected: expected, actual: 0)
        }
        guard expected == actual else {
            return hardFail(.strokeCountMismatch(expected: expected, actual: actual),
                            expected: expected, actual: actual)
        }

        // Step A — Normalize user strokes into a shared [0,1]² box
        // (templates are already normalized by the preprocessing script).
        let normalizedUser = normalizeCharacter(strokes: userStrokes)
        let templateStrokes = template.strokes.map { $0.points }

        // Resample both to a common number of points along arc length.
        let u = normalizedUser.map { resample($0, to: config.samplePoints) }
        let t = templateStrokes.map { resample($0, to: config.samplePoints) }

        // Step B — Build cost matrix. For each (user_i, template_j) pair, cost is the
        // minimum of forward and reversed distance (so shape comparison is direction-agnostic).
        // Remember which direction won so we can report direction correctness later.
        let n = u.count
        var cost = Array(repeating: Array(repeating: Double.infinity, count: n), count: n)
        var wentForward = Array(repeating: Array(repeating: true, count: n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                let fwd = avgPointDistance(u[i], t[j])
                let rev = avgPointDistance(Array(u[i].reversed()), t[j])
                if fwd <= rev {
                    cost[i][j] = fwd
                    wentForward[i][j] = true
                } else {
                    cost[i][j] = rev
                    wentForward[i][j] = false
                }
            }
        }

        // Find the optimal user→template assignment (minimize total cost).
        // Kana have ≤ ~5 strokes so brute-force over permutations is fine (≤ 120 iterations).
        let (assignment, _) = bestAssignment(cost: cost)

        // Step C+D — Build per-stroke details and aggregate flags.
        var details: [StrokeValidation] = []
        var distSum = 0.0
        for i in 0..<n {
            let j = assignment[i]
            let d = cost[i][j]
            details.append(StrokeValidation(
                userIndex: i,
                matchedTemplateIndex: j,
                distance: d,
                shapeOk: d <= config.shapeThreshold,
                directionOk: wentForward[i][j]
            ))
            distSum += d
        }

        let passing = details.filter { $0.shapeOk }.count
        let shapeCorrect = Double(passing) / Double(n) >= config.shapeAcceptance
        let orderCorrect = (0..<n).allSatisfy { assignment[$0] == $0 }
        let directionCorrect = !config.checkDirection || details.allSatisfy { $0.directionOk }

        return ValidationResult(
            expectedStrokeCount: expected,
            actualStrokeCount: actual,
            shapeCorrect: shapeCorrect,
            orderCorrect: orderCorrect,
            directionCorrect: directionCorrect,
            strokeDetails: details,
            failure: nil,
            averageDistance: distSum / Double(n)
        )
    }

    /// Convenience overload for PencilKit strokes.
    static func validate(
        pkStrokes: [PKStroke],
        template: KanaTemplate,
        config: ValidationConfig = .default
    ) -> ValidationResult {
        let points = pkStrokes.map { stroke in stroke.path.map(\.location) }
        return validate(userStrokes: points, template: template, config: config)
    }

    // MARK: - Normalization

    /// Map all strokes of a character into [0,1]² using the union bbox, preserving
    /// aspect ratio (scale by the longer side, center the shorter one).
    /// Relative positions between strokes are preserved — critical so "い" (two vertical
    /// strokes) doesn't collapse to a single unit bar.
    private static func normalizeCharacter(strokes: [[CGPoint]]) -> [[CGPoint]] {
        let all = strokes.flatMap { $0 }
        guard !all.isEmpty else { return strokes }
        let xs = all.map { Double($0.x) }
        let ys = all.map { Double($0.y) }
        let minX = xs.min()!, maxX = xs.max()!
        let minY = ys.min()!, maxY = ys.max()!
        let w = max(maxX - minX, 1e-9)
        let h = max(maxY - minY, 1e-9)
        let scale = max(w, h)
        let offX = (scale - w) / 2
        let offY = (scale - h) / 2
        return strokes.map { stroke in
            stroke.map { p in
                CGPoint(
                    x: (Double(p.x) - minX + offX) / scale,
                    y: (Double(p.y) - minY + offY) / scale
                )
            }
        }
    }

    // MARK: - Resampling

    /// Resample a polyline to `n` equidistant points along its arc length.
    /// This is what makes comparing strokes of different raw densities meaningful:
    /// after resampling both have `n` points we can pair index-by-index.
    private static func resample(_ points: [CGPoint], to n: Int) -> [CGPoint] {
        guard points.count > 1, n > 1 else {
            return Array(repeating: points.first ?? .zero, count: n)
        }
        // Cumulative arc length at each original point.
        var cum: [Double] = [0]
        for i in 1..<points.count {
            let dx = Double(points[i].x - points[i - 1].x)
            let dy = Double(points[i].y - points[i - 1].y)
            cum.append(cum[i - 1] + hypot(dx, dy))
        }
        let total = cum.last!
        guard total > 0 else { return Array(repeating: points[0], count: n) }

        var out: [CGPoint] = []
        out.reserveCapacity(n)
        var seg = 1
        for i in 0..<n {
            let target = Double(i) / Double(n - 1) * total
            while seg < cum.count - 1 && cum[seg] < target { seg += 1 }
            let segLen = cum[seg] - cum[seg - 1]
            let t = segLen > 0 ? (target - cum[seg - 1]) / segLen : 0
            let x = Double(points[seg - 1].x) + t * Double(points[seg].x - points[seg - 1].x)
            let y = Double(points[seg - 1].y) + t * Double(points[seg].y - points[seg - 1].y)
            out.append(CGPoint(x: x, y: y))
        }
        return out
    }

    // MARK: - Distance

    /// Average Euclidean distance between two equal-length point arrays.
    /// After resampling, both inputs have `config.samplePoints` points — so this is a
    /// direct pointwise comparison. It's O(n) and works well for sparse/open curves.
    /// (Fréchet/DTW would be more robust to reparameterization but aren't needed once
    ///  we've already arc-length-resampled.)
    private static func avgPointDistance(_ a: [CGPoint], _ b: [CGPoint]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return .infinity }
        var sum = 0.0
        for i in 0..<a.count {
            sum += hypot(Double(a[i].x - b[i].x), Double(a[i].y - b[i].y))
        }
        return sum / Double(a.count)
    }

    // MARK: - Assignment

    /// Brute-force optimal assignment (minimize total cost). Correct for any N but only
    /// practical for small N. Kana go up to ~5 strokes → 120 permutations max. Trivial.
    private static func bestAssignment(cost: [[Double]]) -> (assignment: [Int], total: Double) {
        let n = cost.count
        guard n > 0 else { return ([], 0) }
        var indices = Array(0..<n)
        var best = indices
        var bestCost = Double.infinity
        permute(&indices, 0) { perm in
            var c = 0.0
            for i in 0..<n { c += cost[i][perm[i]] }
            if c < bestCost { bestCost = c; best = perm }
        }
        return (best, bestCost)
    }

    /// Standard in-place Heap-style permutation generator.
    private static func permute(_ a: inout [Int], _ k: Int, _ body: ([Int]) -> Void) {
        if k == a.count - 1 { body(a); return }
        for i in k..<a.count {
            a.swapAt(k, i)
            permute(&a, k + 1, body)
            a.swapAt(k, i)
        }
    }

    // MARK: - Failure helper

    private static func hardFail(_ failure: ValidationResult.Failure,
                                 expected: Int, actual: Int) -> ValidationResult {
        ValidationResult(
            expectedStrokeCount: expected,
            actualStrokeCount: actual,
            shapeCorrect: false,
            orderCorrect: false,
            directionCorrect: false,
            strokeDetails: [],
            failure: failure,
            averageDistance: .infinity
        )
    }
}
