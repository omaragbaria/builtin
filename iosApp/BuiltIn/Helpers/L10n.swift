import Foundation
import SwiftUI

/// Runtime-switchable localization. Reads the user's chosen language from
/// `UserDefaults` and looks up strings from the matching `.lproj` bundle,
/// so the UI updates without an app restart.
///
/// Keys mirror the layout in `webApp/src/main/resources/messages*.properties`
/// so translators only have to maintain one canonical key namespace.
enum L10n {
    static let userDefaultsKey = "selectedLanguage"

    /// Supported languages — matches the webApp's locale set.
    enum Language: String, CaseIterable, Identifiable {
        case en, he, ar, ru, zh
        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .en: return "English"
            case .he: return "עברית"
            case .ar: return "العربية"
            case .ru: return "Русский"
            case .zh: return "中文"
            }
        }

        var flag: String {
            switch self {
            case .en: return "🇺🇸"
            case .he: return "🇮🇱"
            case .ar: return "🇸🇦"
            case .ru: return "🇷🇺"
            case .zh: return "🇨🇳"
            }
        }

        var isRTL: Bool { self == .he || self == .ar }

        /// Folder name under Resources. Chinese gets the simplified-Han suffix
        /// Apple expects.
        var lprojCode: String {
            switch self {
            case .zh: return "zh-Hans"
            default:  return rawValue
            }
        }
    }

    /// Current language. Defaults to English if nothing's been picked.
    static var current: Language {
        get {
            if let raw = UserDefaults.standard.string(forKey: userDefaultsKey),
               let lang = Language(rawValue: raw) {
                return lang
            }
            return .en
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: userDefaultsKey)
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }

    /// Look up a key in the currently-selected language's bundle.
    /// Falls back to English, then to the raw key.
    static func t(_ key: String) -> String {
        if let path = Bundle.main.path(forResource: current.lprojCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let value = bundle.localizedString(forKey: key, value: nil, table: nil)
            if value != key { return value }
        }
        // Fall back to English
        if let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: key, table: nil)
        }
        return key
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

/// `Text` initializer that looks the key up through `L10n` and re-renders
/// when the language changes.
struct LocalizedText: View {
    let key: String
    @State private var refreshTrigger = UUID()

    init(_ key: String) { self.key = key }

    var body: some View {
        Text(L10n.t(key))
            .id(refreshTrigger)
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                refreshTrigger = UUID()
            }
    }
}
