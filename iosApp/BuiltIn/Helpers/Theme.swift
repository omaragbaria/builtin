import SwiftUI
import UIKit

/// Brand palette extracted from `webApp/src/main/resources/static/img/logo.svg`
/// and the Bootstrap-derived navbar / button colors used in the webApp templates.
///
/// All colors except `amber` (which is the brand identity) shift slightly for
/// dark mode so they keep enough contrast against `systemBackground`.
enum Theme {
    /// Amber accent — used in the logo's shorter building and as the
    /// primary action color in the webApp ("btn-warning"). Same shade in both
    /// modes — it's the brand identity.
    static let amber  = Color(red: 0.961, green: 0.620, blue: 0.043)   // #f59e0b
    /// Dark navy used in the logo's taller building and as the navbar
    /// background. In dark mode we lighten it for legibility against the
    /// dark system background.
    static let navy   = dynamic(light: UIColor(red: 0.118, green: 0.227, blue: 0.373, alpha: 1.0),
                                dark:  UIColor(red: 0.42,  green: 0.59,  blue: 0.81,  alpha: 1.0))

    /// Bootstrap-semantic colors; light variants match the webApp,
    /// dark variants are picked to keep ~4.5:1 contrast on dark backgrounds.
    static let success = dynamic(light: UIColor(red: 0.098, green: 0.529, blue: 0.329, alpha: 1),
                                 dark:  UIColor(red: 0.30,  green: 0.78,  blue: 0.50,  alpha: 1))
    static let info    = dynamic(light: UIColor(red: 0.043, green: 0.671, blue: 0.737, alpha: 1),
                                 dark:  UIColor(red: 0.34,  green: 0.82,  blue: 0.86,  alpha: 1))
    static let primary = dynamic(light: UIColor(red: 0.051, green: 0.431, blue: 0.992, alpha: 1),
                                 dark:  UIColor(red: 0.45,  green: 0.69,  blue: 1.0,   alpha: 1))
    static let warning = dynamic(light: UIColor(red: 1.0,   green: 0.760, blue: 0.027, alpha: 1),
                                 dark:  UIColor(red: 1.0,   green: 0.82,  blue: 0.28,  alpha: 1))
    static let danger  = dynamic(light: UIColor(red: 0.863, green: 0.208, blue: 0.271, alpha: 1),
                                 dark:  UIColor(red: 1.0,   green: 0.45,  blue: 0.50,  alpha: 1))

    /// Convenience tint for SwiftUI's accent color.
    static let tint = amber

    private static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
}

/// The two-building wordmark, rendered from SVG primitives so we don't
/// have to ship a separate image asset for every screen size.
struct BrandLogo: View {
    enum Style { case wordmark, icon }
    var style: Style = .icon
    var size: CGFloat = 64

    var body: some View {
        Canvas { context, _ in
            // Geometry mirrors logo-icon.svg (64×64 viewBox).
            // Left building (amber, shorter)
            context.fill(
                Path(roundedRect: CGRect(x: 2, y: 22, width: 22, height: 40), cornerRadius: 2),
                with: .color(Theme.amber)
            )
            for row in [28, 38, 48] {
                for col in [6, 14] {
                    context.fill(
                        Path(roundedRect: CGRect(x: col, y: row, width: 5, height: 5), cornerRadius: 0.5),
                        with: .color(Theme.navy.opacity(0.65))
                    )
                }
            }
            // Right building (navy, taller)
            context.fill(
                Path(roundedRect: CGRect(x: 40, y: 6, width: 22, height: 56), cornerRadius: 2),
                with: .color(Theme.navy)
            )
            for row in [12, 22, 32, 42, 52] {
                for col in [44, 52] {
                    context.fill(
                        Path(roundedRect: CGRect(x: col, y: row, width: 5, height: 5), cornerRadius: 0.5),
                        with: .color(Theme.amber.opacity(0.85))
                    )
                }
            }
        }
        .frame(width: size, height: size)
        .scaledToFit()
        .accessibilityLabel(Text("BuiltIn"))
    }
}
