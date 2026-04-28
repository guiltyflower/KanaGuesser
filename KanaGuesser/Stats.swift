import Foundation
import Observation

struct KanaStat: Codable, Hashable {
    var seen: Int
    var correct: Int

    var accuracy: Double {
        seen > 0 ? Double(correct) / Double(seen) : 0
    }
}

struct ModeStat: Codable, Hashable {
    var gamesPlayed: Int
    var totalCorrect: Int
    var bestScore: Int

    var averageCorrect: Double {
        gamesPlayed > 0 ? Double(totalCorrect) / Double(gamesPlayed) : 0
    }
}

struct PerfectStreakStat: Codable, Hashable {
    var current: Int = 0
    var best: Int = 0
}

struct RetryRecoveryStat: Codable, Hashable {
    var totalWrongs: Int = 0
    var totalRecovered: Int = 0

    var rate: Double {
        totalWrongs > 0 ? Double(totalRecovered) / Double(totalWrongs) : 0
    }
}

struct DailyStreakStat: Codable, Hashable {
    var lastSessionDate: Date?
    var current: Int = 0
    var best: Int = 0
}

/// Per-kana and per-mode practice statistics. Persisted in UserDefaults as JSON.
/// Stats are recorded only from the Learn mode — Multiplayer mixes two players and would pollute the data.
@Observable
final class StatsStore {
    private static let storageKey = "stats_v3"

    var perKana: [String: KanaStat]
    /// Keyed by round size (5, 10, 15, ...).
    var perMode: [Int: ModeStat]
    var perfect: PerfectStreakStat
    var retry: RetryRecoveryStat
    var daily: DailyStreakStat

    private struct Snapshot: Codable {
        var perKana: [String: KanaStat]
        var perMode: [Int: ModeStat]
        var perfect: PerfectStreakStat
        var retry: RetryRecoveryStat
        var daily: DailyStreakStat
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let snap = try? JSONDecoder().decode(Snapshot.self, from: data) {
            self.perKana = snap.perKana
            self.perMode = snap.perMode
            self.perfect = snap.perfect
            self.retry = snap.retry
            self.daily = snap.daily
        } else {
            self.perKana = [:]
            self.perMode = [:]
            self.perfect = .init()
            self.retry = .init()
            self.daily = .init()
        }
    }

    // MARK: - Recording

    func record(_ outcomes: [(Kana, Bool)]) {
        for (kana, ok) in outcomes {
            var s = perKana[kana.id] ?? KanaStat(seen: 0, correct: 0)
            s.seen += 1
            if ok { s.correct += 1 }
            perKana[kana.id] = s
        }
        persist()
    }

    func recordGame(rounds: Int, correct: Int) {
        var s = perMode[rounds] ?? ModeStat(gamesPlayed: 0, totalCorrect: 0, bestScore: 0)
        s.gamesPlayed += 1
        s.totalCorrect += correct
        s.bestScore = max(s.bestScore, correct)
        perMode[rounds] = s

        // Perfect-game streak
        if correct == rounds {
            perfect.current += 1
            perfect.best = max(perfect.best, perfect.current)
        } else {
            perfect.current = 0
        }

        // Daily streak: 0-day diff = same day, 1-day = consecutive, ≥2 = gap.
        let now = Date()
        let cal = Calendar.current
        if let last = daily.lastSessionDate {
            let diff = cal.dateComponents([.day], from: cal.startOfDay(for: last), to: cal.startOfDay(for: now)).day ?? 0
            if diff >= 2 {
                daily.current = 1
            } else if diff == 1 {
                daily.current += 1
            }
        } else {
            daily.current = 1
        }
        daily.best = max(daily.best, daily.current)
        daily.lastSessionDate = now

        persist()
    }

    func recordRetry(wrongs: Int, recovered: Int) {
        retry.totalWrongs += wrongs
        retry.totalRecovered += recovered
        persist()
    }

    /// Aggregate seen/correct/accuracy for one script across all its kanas.
    func accuracy(for script: Script) -> (seen: Int, correct: Int, accuracy: Double) {
        let prefix = script.rawValue + "-"
        var seen = 0
        var correct = 0
        for (id, stat) in perKana where id.hasPrefix(prefix) {
            seen += stat.seen
            correct += stat.correct
        }
        return (seen, correct, seen > 0 ? Double(correct) / Double(seen) : 0)
    }

    // MARK: - Reads

    func stat(for kana: Kana) -> KanaStat? {
        perKana[kana.id]
    }

    var totalSeen: Int { perKana.values.reduce(0) { $0 + $1.seen } }
    var totalCorrect: Int { perKana.values.reduce(0) { $0 + $1.correct } }
    var totalGames: Int { perMode.values.reduce(0) { $0 + $1.gamesPlayed } }
    var overallAccuracy: Double {
        totalSeen > 0 ? Double(totalCorrect) / Double(totalSeen) : 0
    }

    /// Returns the kanas (with stats) sorted by accuracy. Kanas with `seen < minSeen` are filtered out
    /// to avoid noise from one-shot mistakes.
    func sortedByAccuracy(among kanas: [Kana], ascending: Bool, limit: Int, minSeen: Int = 3) -> [(Kana, KanaStat)] {
        let pairs: [(Kana, KanaStat)] = kanas.compactMap { k in
            guard let s = perKana[k.id], s.seen >= minSeen else { return nil }
            return (k, s)
        }
        let sorted = pairs.sorted { lhs, rhs in
            ascending ? lhs.1.accuracy < rhs.1.accuracy : lhs.1.accuracy > rhs.1.accuracy
        }
        return Array(sorted.prefix(limit))
    }

    func resetAll() {
        perKana = [:]
        perMode = [:]
        perfect = .init()
        retry = .init()
        daily = .init()
        persist()
    }

    private func persist() {
        let snap = Snapshot(perKana: perKana, perMode: perMode, perfect: perfect, retry: retry, daily: daily)
        if let data = try? JSONEncoder().encode(snap) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
