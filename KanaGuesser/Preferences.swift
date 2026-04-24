import Foundation
import Observation

/// User preferences persisted via UserDefaults. Inject at the root and read with
/// `@Environment(PreferencesStore.self)` — changes trigger re-renders in observing views.
@Observable
final class PreferencesStore {
    private static let hiraganaKey = "enable_hiragana"
    private static let katakanaKey = "enable_katakana"
    private static let roundsKey = "rounds_per_round"
    private static let recoveryKey = "recovery_passes"
    private static let soundsKey = "sounds_enabled"
    private static let hapticsKey = "haptics_enabled"

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

    var rounds: Int {
        didSet { UserDefaults.standard.set(rounds, forKey: Self.roundsKey) }
    }

    var recoveryPasses: Int {
        didSet { UserDefaults.standard.set(recoveryPasses, forKey: Self.recoveryKey) }
    }

    var soundsEnabled: Bool {
        didSet { UserDefaults.standard.set(soundsEnabled, forKey: Self.soundsKey) }
    }

    var hapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: Self.hapticsKey) }
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

        let storedRounds = defs.integer(forKey: Self.roundsKey)
        self.rounds = storedRounds == 0 ? 10 : storedRounds

        let storedRecovery = defs.integer(forKey: Self.recoveryKey)
        self.recoveryPasses = storedRecovery == 0 ? 3 : storedRecovery

        self.soundsEnabled = defs.object(forKey: Self.soundsKey) as? Bool ?? true
        self.hapticsEnabled = defs.object(forKey: Self.hapticsKey) as? Bool ?? true
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
