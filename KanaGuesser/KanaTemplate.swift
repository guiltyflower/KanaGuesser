import Foundation
import CoreGraphics

/// A single stroke template: a polyline of points in normalized [0,1]² space,
/// ordered from stroke start to stroke end (direction matters).
struct StrokeTemplate: Codable, Hashable {
    /// Stored as `[[x, y], ...]` for compact JSON produced by the preprocessing script.
    private let points2D: [[Double]]

    var points: [CGPoint] {
        points2D.map { CGPoint(x: $0[0], y: $0[1]) }
    }

    init(points: [CGPoint]) {
        self.points2D = points.map { [Double($0.x), Double($0.y)] }
    }

    enum CodingKeys: String, CodingKey { case points2D = "points" }
}

/// A kana character with its strokes in canonical drawing order.
struct KanaTemplate: Codable, Hashable {
    let character: String   // "あ"
    let romaji: String      // "a"
    let strokes: [StrokeTemplate]

    var strokeCount: Int { strokes.count }
}

/// Top-level container decoded from the bundled `kana_templates.json`.
struct KanaTemplateBundle: Codable {
    let templates: [KanaTemplate]

    /// Load the bundle from the app's main bundle. Throws if the file is missing
    /// (run `scripts/kanjivg_to_templates.py` to generate it).
    static func loadBundled(bundle: Bundle = .main) throws -> KanaTemplateBundle {
        guard let url = bundle.url(forResource: "kana_templates", withExtension: "json") else {
            throw NSError(
                domain: "KanaTemplate", code: 1,
                userInfo: [NSLocalizedDescriptionKey:
                    "kana_templates.json not found. Run scripts/kanjivg_to_templates.py."]
            )
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(KanaTemplateBundle.self, from: data)
    }

    /// Dictionary keyed by character for O(1) lookup.
    func byCharacter() -> [String: KanaTemplate] {
        Dictionary(uniqueKeysWithValues: templates.map { ($0.character, $0) })
    }
}
