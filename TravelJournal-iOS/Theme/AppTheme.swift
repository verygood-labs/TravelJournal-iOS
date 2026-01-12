import SwiftUI

// MARK: - App Theme
/// Centralized theme configuration for the entire app.
/// Change values here to update styling globally.

struct AppTheme {
    
    // MARK: - Colors
    struct Colors {
        // Primary palette (currently gold)
        static let primary = Color(hex: "c9a227")
        static let primaryLight = Color(hex: "d4af37")
        static let primaryPale = Color(hex: "f4e5b0")
        
        // Background colors
        static let backgroundDark = Color(hex: "0d2436")
        static let backgroundMedium = Color(hex: "1a3a52")
        static let backgroundLight = Color(hex: "16213e")
        
        // Text colors
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.5)
        static let textAccent = Color(hex: "c9a227")
        static let textAccentMuted = Color(hex: "c9a227").opacity(0.8)
        
        // UI Element colors
        static let inputBackground = Color.white.opacity(0.05)
        static let inputBorder = primary.opacity(0.3)
        static let inputBorderFocused = primary
        static let divider = primary.opacity(0.2)
        
        // Accent overlays
        static let primaryOverlay = primary.opacity(0.15)
        static let primaryOverlayLight = primary.opacity(0.08)
    }
    
    // MARK: - Typography
    struct Typography {
        // Font families - change these to swap fonts globally
        private static let serifFontName: String? = nil  // nil = system serif
        private static let monoFontName: String? = nil   // nil = system monospaced
        
        // MARK: Serif fonts (for headings)
        static func serifLarge() -> Font {
            if let fontName = serifFontName {
                return .custom(fontName, size: 36)
            }
            return .system(size: 36, weight: .bold, design: .serif)
        }
        
        static func serifMedium() -> Font {
            if let fontName = serifFontName {
                return .custom(fontName, size: 28)
            }
            return .system(size: 28, weight: .semibold, design: .serif)
        }
        
        static func serifSmall() -> Font {
            if let fontName = serifFontName {
                return .custom(fontName, size: 22)
            }
            return .system(size: 22, weight: .semibold, design: .serif)
        }
        
        // MARK: Monospace fonts (for body/labels)
        static func monoLarge() -> Font {
            if let fontName = monoFontName {
                return .custom(fontName, size: 16)
            }
            return .system(size: 16, weight: .medium, design: .monospaced)
        }
        
        static func monoMedium() -> Font {
            if let fontName = monoFontName {
                return .custom(fontName, size: 14)
            }
            return .system(size: 14, weight: .medium, design: .monospaced)
        }
        
        static func monoSmall() -> Font {
            if let fontName = monoFontName {
                return .custom(fontName, size: 12)
            }
            return .system(size: 12, weight: .regular, design: .monospaced)
        }
        
        static func monoCaption() -> Font {
            if let fontName = monoFontName {
                return .custom(fontName, size: 10)
            }
            return .system(size: 10, weight: .regular, design: .monospaced)
        }
        
        static func monoTiny() -> Font {
            if let fontName = monoFontName {
                return .custom(fontName, size: 9)
            }
            return .system(size: 9, weight: .regular, design: .monospaced)
        }
        
        // MARK: Button text
        static func button() -> Font {
            if let fontName = monoFontName {
                return .custom(fontName, size: 14)
            }
            return .system(size: 14, weight: .semibold, design: .monospaced)
        }
        
        // MARK: Label styling
        static func inputLabel() -> Font {
            if let fontName = monoFontName {
                return .custom(fontName, size: 10)
            }
            return .system(size: 10, weight: .medium, design: .monospaced)
        }
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxxs: CGFloat = 4
        static let xxs: CGFloat = 8
        static let xs: CGFloat = 12
        static let sm: CGFloat = 16
        static let md: CGFloat = 20
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        static let xxxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let pill: CGFloat = 50
    }
    
    // MARK: - Animation
    struct Animation {
        static let fast: Double = 0.2
        static let medium: Double = 0.3
        static let slow: Double = 0.6
        static let pulse: Double = 3.0
        static let float: Double = 4.0
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}