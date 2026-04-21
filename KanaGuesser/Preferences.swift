import Foundation
import Observation

/// User preferences persisted via UserDefaults. Inject at the root and read with
/// `@Environment(PreferencesStore.self)` — changes trigger re-renders in observing views.
@Observable
final class PreferencesStore {
    private static let hiraganaKey = "enable_hiragana"
    private static let katakanaKey = "enable_katakana"

    /// Guarded so it can never become empty (we'd have no pool to draw from).
    var selectedScripts: Set<Script> {
        didSet {
            if selectedScripts.isEmpty {
                selectedScripts = oldValue
                return
            }
            UserDefaults.standard.set(selectedScripts.contains(.hiragana), forKey: Self.hiraganaKey)
            UserDefaults.standard.set(selectedScripts.contains(.katakana), forKey: Self.katakanaKey)
        }
    }

    init() {
        let defs = UserDefaults.standard
        // Distinguish "never set" from "explicitly false": default is BOTH enabled.
        let hiraganaSet = defs.object(forKey: Self.hiraganaKey) != nil
        let katakanaSet = defs.object(forKey: Self.katakanaKey) != nil

        var s: Set<Script> = []
        if !hiraganaSet || defs.bool(forKey: Self.hiraganaKey) { s.insert(.hiragana) }
        if !katakanaSet || defs.bool(forKey: Self.katakanaKey) { s.insert(.katakana) }
        if s.isEmpty { s = [.hiragana, .katakana] }
        self.selectedScripts = s
    }

    /// Toggle a script on/off, but prevent emptying the set.
    func toggle(_ script: Script) {
        var s = selectedScripts
        if s.contains(script) {
            guard s.count > 1 else { return }
            s.remove(script)
        } else {
            s.insert(script)
        }
        selectedScripts = s
    }
}
