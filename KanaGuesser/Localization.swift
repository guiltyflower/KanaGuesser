import Foundation
import SwiftUI
import Observation

// MARK: - Language

enum Language: String, CaseIterable, Identifiable, Hashable {
    case italian = "it"
    case english = "en"
    case french  = "fr"

    var id: String { rawValue }

    /// Self-referential display name (the way speakers of that language call it).
    var nativeName: String {
        switch self {
        case .italian: return "Italiano"
        case .english: return "English"
        case .french:  return "Français"
        }
    }

    var flag: String {
        switch self {
        case .italian: return "🇮🇹"
        case .english: return "🇬🇧"
        case .french:  return "🇫🇷"
        }
    }
}

// MARK: - Keys

/// All user-facing strings live in this enum. Add here, then translate in `translations`.
enum LKey: String {
    // Menu
    case menuSubtitle
    case menuAlphabets
    case modeLearnTitle
    case modeLearnSubtitle
    case modeChallengeTitle
    case modeChallengeSubtitle

    // Game round
    case gameDrawThe
    case gameConnector
    case gameCorrectCount       // "%d corrette"
    case gameAnswer
    case gameWrong
    case gameRight
    case gameClear
    case gameShowAnswer
    case gameReview             // header when in retry phase

    // Results
    case resultPerfect
    case resultGreat
    case resultGood
    case resultKeepGoing
    case resultNewRound
    case resultMenu
    case resultReviewHeading
    case resultReviewRecovered  // "%d / %d recuperati"
    case resultReviewStill      // "Ancora %d da rivedere"
    case retryReadyScore        // "Hai indovinato %d su %d."
    case retryReadyCount        // "Ora ripassiamo i %d kana sbagliati."
    case retryReadyStart        // button: "Inizia ripasso"

    // Multiplayer
    case mpTurnOf               // prefix line: "Tocca al" / "It's" / "C'est au tour du"
    case mpPlayer               // "Giocatore %d" / "Player %d" / "Joueur %d"
    case mpPlayerGot            // "Giocatore %d ha fatto"
    case mpIntro                // "Disegnerai %d kana. Poi toccherà al Giocatore 2."
    case mpStart
    case mpNext
    case mpTie
    case mpWinner               // "Vince il Giocatore %d"
    case mpRematch
    case mpOutOf                // "su %d"

    // Settings
    case settingsTitle
    case settingsLanguage
    case settingsDone

    // Validation demo
    case valWrite
    case valStrokesCount        // "%d tratti"
    case valCheck
    case valWrongStrokes        // "Hai fatto %d tratti, ne servono %d."
    case valEmpty
    case valShape
    case valOrder
    case valDirection
    case valStroke              // "Tratto %d"
    case valWasStroke           // "→ era il tratto %d"
    case valReversed
    case valAvgDistance         // "Distanza media: %.3f"
}

// MARK: - Translations

private let translations: [Language: [LKey: String]] = [

    .italian: [
        .menuSubtitle: "Scegli una modalità",
        .menuAlphabets: "Alfabeti",
        .modeLearnTitle: "Impara",
        .modeLearnSubtitle: "Allenati da solo",
        .modeChallengeTitle: "Sfida",
        .modeChallengeSubtitle: "2 giocatori a turni",

        .gameDrawThe: "Disegna il",
        .gameConnector: "di",
        .gameCorrectCount: "%d corrette",
        .gameAnswer: "Risposta",
        .gameWrong: "Sbagliato",
        .gameRight: "Giusto",
        .gameClear: "Pulisci",
        .gameShowAnswer: "Mostra risposta",
        .gameReview: "Ripasso",

        .resultPerfect: "Perfetto!",
        .resultGreat: "Ottimo!",
        .resultGood: "Bene",
        .resultKeepGoing: "Continua ad allenarti",
        .resultNewRound: "Nuovo round",
        .resultMenu: "Menu",
        .resultReviewHeading: "Ripasso",
        .resultReviewRecovered: "%d / %d recuperati",
        .resultReviewStill: "Ancora %d da rivedere",
        .retryReadyScore: "Hai indovinato %d su %d.",
        .retryReadyCount: "Ora ripassiamo i %d kana sbagliati.",
        .retryReadyStart: "Inizia ripasso",

        .mpTurnOf: "Tocca al",
        .mpPlayer: "Giocatore %d",
        .mpPlayerGot: "Giocatore %d ha fatto",
        .mpIntro: "Disegnerai %d kana. Poi toccherà al Giocatore 2.",
        .mpStart: "Inizia",
        .mpNext: "Avanti",
        .mpTie: "Pareggio!",
        .mpWinner: "Vince il Giocatore %d",
        .mpRematch: "Rivincita",
        .mpOutOf: "su %d",

        .settingsTitle: "Impostazioni",
        .settingsLanguage: "Lingua",
        .settingsDone: "Fine",

        .valWrite: "Scrivi",
        .valStrokesCount: "%d tratti",
        .valCheck: "Verifica",
        .valWrongStrokes: "Hai fatto %d tratti, ne servono %d.",
        .valEmpty: "Nessun tratto rilevato.",
        .valShape: "Forma",
        .valOrder: "Ordine",
        .valDirection: "Direzione",
        .valStroke: "Tratto %d",
        .valWasStroke: "→ era il tratto %d",
        .valReversed: "↺ direzione invertita",
        .valAvgDistance: "Distanza media: %.3f",
    ],

    .english: [
        .menuSubtitle: "Choose a mode",
        .menuAlphabets: "Alphabets",
        .modeLearnTitle: "Learn",
        .modeLearnSubtitle: "Practice solo",
        .modeChallengeTitle: "Challenge",
        .modeChallengeSubtitle: "2 players, taking turns",

        .gameDrawThe: "Draw the",
        .gameConnector: "for",
        .gameCorrectCount: "%d correct",
        .gameAnswer: "Answer",
        .gameWrong: "Wrong",
        .gameRight: "Right",
        .gameClear: "Clear",
        .gameShowAnswer: "Show answer",
        .gameReview: "Review",

        .resultPerfect: "Perfect!",
        .resultGreat: "Great!",
        .resultGood: "Nice",
        .resultKeepGoing: "Keep practicing",
        .resultNewRound: "New round",
        .resultMenu: "Menu",
        .resultReviewHeading: "Review",
        .resultReviewRecovered: "%d / %d recovered",
        .resultReviewStill: "%d still to review",
        .retryReadyScore: "You got %d out of %d.",
        .retryReadyCount: "Let's review the %d kana you missed.",
        .retryReadyStart: "Start review",

        .mpTurnOf: "It's",
        .mpPlayer: "Player %d",
        .mpPlayerGot: "Player %d got",
        .mpIntro: "You'll draw %d kana. Then it's Player 2's turn.",
        .mpStart: "Start",
        .mpNext: "Next",
        .mpTie: "Tie!",
        .mpWinner: "Player %d wins",
        .mpRematch: "Rematch",
        .mpOutOf: "out of %d",

        .settingsTitle: "Settings",
        .settingsLanguage: "Language",
        .settingsDone: "Done",

        .valWrite: "Write",
        .valStrokesCount: "%d strokes",
        .valCheck: "Check",
        .valWrongStrokes: "You drew %d strokes, %d expected.",
        .valEmpty: "No stroke detected.",
        .valShape: "Shape",
        .valOrder: "Order",
        .valDirection: "Direction",
        .valStroke: "Stroke %d",
        .valWasStroke: "→ should be stroke %d",
        .valReversed: "↺ drawn in reverse",
        .valAvgDistance: "Average distance: %.3f",
    ],

    .french: [
        .menuSubtitle: "Choisis un mode",
        .menuAlphabets: "Alphabets",
        .modeLearnTitle: "Apprendre",
        .modeLearnSubtitle: "Entraîne-toi seul",
        .modeChallengeTitle: "Défi",
        .modeChallengeSubtitle: "2 joueurs, à tour de rôle",

        .gameDrawThe: "Dessine le",
        .gameConnector: "pour",
        .gameCorrectCount: "%d corrects",
        .gameAnswer: "Réponse",
        .gameWrong: "Faux",
        .gameRight: "Juste",
        .gameClear: "Effacer",
        .gameShowAnswer: "Voir la réponse",
        .gameReview: "Révision",

        .resultPerfect: "Parfait !",
        .resultGreat: "Excellent !",
        .resultGood: "Bien",
        .resultKeepGoing: "Continue à t'entraîner",
        .resultNewRound: "Nouvelle partie",
        .resultMenu: "Menu",
        .resultReviewHeading: "Révision",
        .resultReviewRecovered: "%d / %d récupérés",
        .resultReviewStill: "Encore %d à revoir",
        .retryReadyScore: "Tu as trouvé %d sur %d.",
        .retryReadyCount: "On révise les %d kana que tu as ratés.",
        .retryReadyStart: "Commencer la révision",

        .mpTurnOf: "C'est au tour du",
        .mpPlayer: "Joueur %d",
        .mpPlayerGot: "Joueur %d a fait",
        .mpIntro: "Tu vas dessiner %d kana. Ensuite, au tour du Joueur 2.",
        .mpStart: "Commencer",
        .mpNext: "Suivant",
        .mpTie: "Égalité !",
        .mpWinner: "Le Joueur %d gagne",
        .mpRematch: "Revanche",
        .mpOutOf: "sur %d",

        .settingsTitle: "Paramètres",
        .settingsLanguage: "Langue",
        .settingsDone: "Terminé",

        .valWrite: "Écris",
        .valStrokesCount: "%d traits",
        .valCheck: "Vérifier",
        .valWrongStrokes: "Tu as fait %d traits, il en faut %d.",
        .valEmpty: "Aucun trait détecté.",
        .valShape: "Forme",
        .valOrder: "Ordre",
        .valDirection: "Direction",
        .valStroke: "Trait %d",
        .valWasStroke: "→ c'était le trait %d",
        .valReversed: "↺ direction inversée",
        .valAvgDistance: "Distance moyenne : %.3f",
    ],
]

// MARK: - Store

/// Observable language store. Inject at the root via `.environment(...)`, read in views
/// via `@Environment(LanguageStore.self)`. Changes to `current` re-render observing views.
@Observable
final class LanguageStore {
    private static let defaultsKey = "app_language"

    var current: Language {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: Self.defaultsKey)
        }
    }

    init() {
        let raw = UserDefaults.standard.string(forKey: Self.defaultsKey) ?? ""
        self.current = Language(rawValue: raw) ?? Self.systemDefault()
    }

    private static func systemDefault() -> Language {
        let code = Locale.current.language.languageCode?.identifier ?? ""
        return Language(rawValue: code) ?? .italian
    }

    /// Translate a key with no substitutions.
    func tr(_ key: LKey) -> String {
        translations[current]?[key]
            ?? translations[.italian]?[key]
            ?? key.rawValue
    }

    /// Translate a key whose value contains printf-style placeholders (`%d`, `%@`, `%.3f`, ...).
    func tr(_ key: LKey, _ args: CVarArg...) -> String {
        String(format: tr(key), arguments: args)
    }
}
