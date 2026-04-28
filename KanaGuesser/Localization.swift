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
    case menuAlphabets
    case modeLearnTitle
    case modeLearnSubtitle
    case modeChallengeTitle
    case modeChallengeSubtitle
    case modeCheatsheetTitle
    case modeCheatsheetSubtitle

    // Cheatsheet
    case cheatsheetTitle
    case cheatsheetSubtitle

    // Game round
    case gameDrawChar           // "Disegna il carattere" — uppercase card label
    case gameAnswer             // "Risposta corretta"
    case gameWrong              // button "Sbagliato"
    case gameRight              // button "Corretto"
    case gameClear              // button "Cancella"
    case gameShowAnswer         // button "Mostra risposta"
    case gameReview             // top-bar label when in retry phase

    // Results
    case resultPerfect
    case resultGreat
    case resultGood
    case resultKeepGoing
    case resultNewRound
    case resultMenu
    case resultRoundCompleted   // header "Round completato"
    case resultTrainingDone     // header "Allenamento completato"
    case resultGreatJob         // hero "Ottimo lavoro!"
    case resultScoreFraction    // hero fraction: "%d su %d"
    case resultReviewOneToGo    // "1 da ripassare"
    case resultReviewManyToGo   // "%d da ripassare"
    case resultYourCharacters   // grid header
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
    case mpTurnEnded            // "Turno concluso"
    case mpPassDevice           // "Passa il dispositivo al"
    case mpStartTurn            // "Inizia turno %@"
    case mpChallengeDone        // "Sfida completata"
    case mpWinnerBadge          // "VINCITORE"

    // Settings
    case settingsTitle
    case settingsLanguage
    case settingsDone
    case settingsScriptsHeader  // uppercase "SILLABARI"
    case settingsMatchHeader    // uppercase "PARTITA"
    case settingsPrefsHeader    // uppercase "PREFERENZE"
    case settingsLanguageHeader // uppercase "LINGUA"
    case settingsRoundsTitle    // "Turni per round"
    case settingsRoundsSub      // "Quanti caratteri disegnare"
    case settingsRecoveryTitle  // "Ripassi caratteri sbagliati"
    case settingsRecoverySub    // "Volte per memorizzare"
    case settingsSounds
    case settingsSoundsSub
    case settingsHaptics
    case settingsHapticsSub

    // Stats
    case statsHeader            // uppercase "STATISTICHE"
    case statsKanaHeader        // uppercase "KANA"
    case statsSummaryTitle      // "Totale"
    case statsSummarySub        // "%d partite · %d%% giusti"
    case statsModeTitle         // "%d domande"
    case statsModeSub           // "%d partite · %.1f media · %d miglior"
    case statsNoData            // "Gioca qualche partita per vedere le statistiche"
    case statsReset             // "Reset statistiche"
    case statsResetConfirm      // "Cancellare tutte le statistiche?"
    case statsResetCancel       // "Annulla"
    case statsHardest           // "Da ripassare"
    case statsMastered          // "Padroneggiati"
    case statsAccuracyShort     // "%d%%"
    case statsScriptsTitle      // "Per sillabario"
    case statsScriptsSub        // "Hiragana %d%% · Katakana %d%%"
    case statsDailyTitle        // "Streak giornaliero"
    case statsDailySub          // "%d giorni · miglior %d"
    case statsDailyLast         // "ultima %@"
    case statsLastToday         // "oggi"
    case statsLastYesterday     // "ieri"
    case statsLastDaysAgo       // "%d giorni fa"
    case statsPerfectTitle      // "Perfetti di fila"
    case statsPerfectSub        // "%d corrente · miglior %d"
    case statsRecoveryTitle     // "Recupero ripasso"
    case statsRecoverySub       // "%d / %d (%d%%)"
    case statsKanaButton        // "Statistiche per kana" (settings row → opens KanaStatsView)
    case kanaStatsTitle         // page title
    case kanaStatsSubtitle      // page subtitle

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
        .menuAlphabets: "Alfabeti",
        .modeLearnTitle: "Impara",
        .modeLearnSubtitle: "Allenati da solo",
        .modeChallengeTitle: "Sfida",
        .modeChallengeSubtitle: "2 giocatori a turni",
        .modeCheatsheetTitle: "CheatSheet",
        .modeCheatsheetSubtitle: "Consulta tutti i kana",

        .cheatsheetTitle: "CheatSheet",
        .cheatsheetSubtitle: "Tocca un kana per vederlo in grande",

        .gameDrawChar: "Disegna il carattere",
        .gameAnswer: "Risposta corretta",
        .gameWrong: "Sbagliato",
        .gameRight: "Corretto",
        .gameClear: "Cancella",
        .gameShowAnswer: "Mostra risposta",
        .gameReview: "Ripasso",

        .resultPerfect: "Perfetto!",
        .resultGreat: "Ottimo!",
        .resultGood: "Bene",
        .resultKeepGoing: "Continua ad allenarti",
        .resultNewRound: "Nuovo round",
        .resultMenu: "Torna alla home",
        .resultRoundCompleted: "Round completato",
        .resultTrainingDone: "Allenamento completato",
        .resultGreatJob: "Ottimo lavoro!",
        .resultScoreFraction: "%d su %d",
        .resultReviewOneToGo: "1 da ripassare",
        .resultReviewManyToGo: "%d da ripassare",
        .resultYourCharacters: "I tuoi caratteri",
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
        .mpWinner: "Vince il\nGiocatore %d",
        .mpRematch: "Rivincita",
        .mpOutOf: "su %d",
        .mpTurnEnded: "Turno concluso",
        .mpPassDevice: "Passa il dispositivo al",
        .mpStartTurn: "Inizia turno %@",
        .mpChallengeDone: "Sfida completata",
        .mpWinnerBadge: "VINCITORE",

        .settingsTitle: "Impostazioni",
        .settingsLanguage: "Lingua",
        .settingsDone: "Fine",
        .settingsScriptsHeader: "SILLABARI",
        .settingsMatchHeader: "PARTITA",
        .settingsPrefsHeader: "PREFERENZE",
        .settingsLanguageHeader: "LINGUA",
        .settingsRoundsTitle: "Turni per round",
        .settingsRoundsSub: "Quanti caratteri disegnare",
        .settingsRecoveryTitle: "Ripassi caratteri sbagliati",
        .settingsRecoverySub: "Volte per memorizzare",
        .settingsSounds: "Suoni",
        .settingsSoundsSub: "Feedback audio",
        .settingsHaptics: "Vibrazione",
        .settingsHapticsSub: "Feedback aptico",

        .statsHeader: "STATISTICHE",
        .statsKanaHeader: "KANA",
        .statsSummaryTitle: "Totale",
        .statsSummarySub: "%d partite · %d%% giusti",
        .statsModeTitle: "%d domande",
        .statsModeSub: "%d partite · %.1f media · %d miglior",
        .statsNoData: "Gioca qualche partita per vedere le statistiche",
        .statsReset: "Reset statistiche",
        .statsResetConfirm: "Cancellare tutte le statistiche?",
        .statsResetCancel: "Annulla",
        .statsHardest: "Da ripassare",
        .statsMastered: "Padroneggiati",
        .statsAccuracyShort: "%d%%",
        .statsScriptsTitle: "Per sillabario",
        .statsScriptsSub: "Hiragana %d%% · Katakana %d%%",
        .statsDailyTitle: "Streak giornaliero",
        .statsDailySub: "%d giorni · miglior %d",
        .statsDailyLast: "ultima %@",
        .statsLastToday: "oggi",
        .statsLastYesterday: "ieri",
        .statsLastDaysAgo: "%d giorni fa",
        .statsPerfectTitle: "Perfetti di fila",
        .statsPerfectSub: "%d corrente · miglior %d",
        .statsRecoveryTitle: "Recupero ripasso",
        .statsRecoverySub: "%d / %d (%d%%)",
        .statsKanaButton: "Statistiche per kana",
        .kanaStatsTitle: "Statistiche per kana",
        .kanaStatsSubtitle: "Accuratezza per ogni carattere",

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
        .menuAlphabets: "Alphabets",
        .modeLearnTitle: "Learn",
        .modeLearnSubtitle: "Practice solo",
        .modeChallengeTitle: "Challenge",
        .modeChallengeSubtitle: "2 players, taking turns",
        .modeCheatsheetTitle: "CheatSheet",
        .modeCheatsheetSubtitle: "Browse every kana",

        .cheatsheetTitle: "CheatSheet",
        .cheatsheetSubtitle: "Tap a kana to see it larger",

        .gameDrawChar: "Draw the character",
        .gameAnswer: "Correct answer",
        .gameWrong: "Wrong",
        .gameRight: "Correct",
        .gameClear: "Clear",
        .gameShowAnswer: "Show answer",
        .gameReview: "Review",

        .resultPerfect: "Perfect!",
        .resultGreat: "Great!",
        .resultGood: "Nice",
        .resultKeepGoing: "Keep practicing",
        .resultNewRound: "New round",
        .resultMenu: "Back to home",
        .resultRoundCompleted: "Round complete",
        .resultTrainingDone: "Training complete",
        .resultGreatJob: "Great job!",
        .resultScoreFraction: "%d out of %d",
        .resultReviewOneToGo: "1 to review",
        .resultReviewManyToGo: "%d to review",
        .resultYourCharacters: "Your characters",
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
        .mpWinner: "Player %d\nwins",
        .mpRematch: "Rematch",
        .mpOutOf: "out of %d",
        .mpTurnEnded: "Turn complete",
        .mpPassDevice: "Pass the device to",
        .mpStartTurn: "Start %@'s turn",
        .mpChallengeDone: "Challenge complete",
        .mpWinnerBadge: "WINNER",

        .settingsTitle: "Settings",
        .settingsLanguage: "Language",
        .settingsDone: "Done",
        .settingsScriptsHeader: "SYLLABARIES",
        .settingsMatchHeader: "GAME",
        .settingsPrefsHeader: "PREFERENCES",
        .settingsLanguageHeader: "LANGUAGE",
        .settingsRoundsTitle: "Turns per round",
        .settingsRoundsSub: "How many characters to draw",
        .settingsRecoveryTitle: "Reviews for missed characters",
        .settingsRecoverySub: "Times to memorize",
        .settingsSounds: "Sounds",
        .settingsSoundsSub: "Audio feedback",
        .settingsHaptics: "Haptics",
        .settingsHapticsSub: "Haptic feedback",

        .statsHeader: "STATS",
        .statsKanaHeader: "KANA",
        .statsSummaryTitle: "Total",
        .statsSummarySub: "%d games · %d%% correct",
        .statsModeTitle: "%d questions",
        .statsModeSub: "%d games · %.1f avg · %d best",
        .statsNoData: "Play a few games to see your stats",
        .statsReset: "Reset stats",
        .statsResetConfirm: "Erase all stats?",
        .statsResetCancel: "Cancel",
        .statsHardest: "To review",
        .statsMastered: "Mastered",
        .statsAccuracyShort: "%d%%",
        .statsScriptsTitle: "By script",
        .statsScriptsSub: "Hiragana %d%% · Katakana %d%%",
        .statsDailyTitle: "Daily streak",
        .statsDailySub: "%d days · best %d",
        .statsDailyLast: "last %@",
        .statsLastToday: "today",
        .statsLastYesterday: "yesterday",
        .statsLastDaysAgo: "%d days ago",
        .statsPerfectTitle: "Perfect streak",
        .statsPerfectSub: "%d current · best %d",
        .statsRecoveryTitle: "Review recovery",
        .statsRecoverySub: "%d / %d (%d%%)",
        .statsKanaButton: "Per-kana stats",
        .kanaStatsTitle: "Per-kana stats",
        .kanaStatsSubtitle: "Accuracy per character",

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
        .menuAlphabets: "Alphabets",
        .modeLearnTitle: "Apprendre",
        .modeLearnSubtitle: "Entraîne-toi seul",
        .modeChallengeTitle: "Défi",
        .modeChallengeSubtitle: "2 joueurs, à tour de rôle",
        .modeCheatsheetTitle: "CheatSheet",
        .modeCheatsheetSubtitle: "Consulte tous les kana",

        .cheatsheetTitle: "CheatSheet",
        .cheatsheetSubtitle: "Touche un kana pour l'agrandir",

        .gameDrawChar: "Dessine le caractère",
        .gameAnswer: "Bonne réponse",
        .gameWrong: "Faux",
        .gameRight: "Correct",
        .gameClear: "Effacer",
        .gameShowAnswer: "Voir la réponse",
        .gameReview: "Révision",

        .resultPerfect: "Parfait !",
        .resultGreat: "Excellent !",
        .resultGood: "Bien",
        .resultKeepGoing: "Continue à t'entraîner",
        .resultNewRound: "Nouvelle partie",
        .resultMenu: "Retour à l'accueil",
        .resultRoundCompleted: "Manche terminée",
        .resultTrainingDone: "Entraînement terminé",
        .resultGreatJob: "Bravo !",
        .resultScoreFraction: "%d sur %d",
        .resultReviewOneToGo: "1 à revoir",
        .resultReviewManyToGo: "%d à revoir",
        .resultYourCharacters: "Tes caractères",
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
        .mpWinner: "Le Joueur %d\ngagne",
        .mpRematch: "Revanche",
        .mpOutOf: "sur %d",
        .mpTurnEnded: "Tour terminé",
        .mpPassDevice: "Passe l'appareil au",
        .mpStartTurn: "Commencer le tour du %@",
        .mpChallengeDone: "Défi terminé",
        .mpWinnerBadge: "GAGNANT",

        .settingsTitle: "Paramètres",
        .settingsLanguage: "Langue",
        .settingsDone: "Terminé",
        .settingsScriptsHeader: "SYLLABAIRES",
        .settingsMatchHeader: "PARTIE",
        .settingsPrefsHeader: "PRÉFÉRENCES",
        .settingsLanguageHeader: "LANGUE",
        .settingsRoundsTitle: "Tours par manche",
        .settingsRoundsSub: "Combien de caractères à dessiner",
        .settingsRecoveryTitle: "Révisions des caractères ratés",
        .settingsRecoverySub: "Fois pour mémoriser",
        .settingsSounds: "Sons",
        .settingsSoundsSub: "Retour audio",
        .settingsHaptics: "Vibrations",
        .settingsHapticsSub: "Retour haptique",

        .statsHeader: "STATISTIQUES",
        .statsKanaHeader: "KANA",
        .statsSummaryTitle: "Total",
        .statsSummarySub: "%d parties · %d%% justes",
        .statsModeTitle: "%d questions",
        .statsModeSub: "%d parties · %.1f moy · %d meilleur",
        .statsNoData: "Joue quelques parties pour voir tes statistiques",
        .statsReset: "Réinitialiser les statistiques",
        .statsResetConfirm: "Effacer toutes les statistiques ?",
        .statsResetCancel: "Annuler",
        .statsHardest: "À réviser",
        .statsMastered: "Maîtrisés",
        .statsAccuracyShort: "%d%%",
        .statsScriptsTitle: "Par syllabaire",
        .statsScriptsSub: "Hiragana %d%% · Katakana %d%%",
        .statsDailyTitle: "Série quotidienne",
        .statsDailySub: "%d jours · meilleure %d",
        .statsDailyLast: "dernière %@",
        .statsLastToday: "aujourd'hui",
        .statsLastYesterday: "hier",
        .statsLastDaysAgo: "il y a %d jours",
        .statsPerfectTitle: "Parties parfaites d'affilée",
        .statsPerfectSub: "%d en cours · meilleure %d",
        .statsRecoveryTitle: "Récupération révision",
        .statsRecoverySub: "%d / %d (%d%%)",
        .statsKanaButton: "Stats par kana",
        .kanaStatsTitle: "Stats par kana",
        .kanaStatsSubtitle: "Précision par caractère",

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

    /// Translate a key whose value contains a single `%@` placeholder, substituting a Swift
    /// String. Needed because `String` does not conform to `CVarArg`.
    func tr(_ key: LKey, string: String) -> String {
        tr(key).replacingOccurrences(of: "%@", with: string)
    }
}
