import SwiftUI

// MARK: - Color hex

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

// MARK: - Design tokens

enum KG {
    enum C {
        static let bgCream       = Color(hex: 0xF6EFC7)
        static let bgCreamDark   = Color(hex: 0xF5EFD8)
        static let divider       = Color(hex: 0xEFEADA)
        static let dividerHard   = Color(hex: 0xE8E2CC)
        static let textPrimary   = Color(hex: 0x0F0F0F)
        static let textSecondary = Color(hex: 0x6A6458)
        static let textTertiary  = Color(hex: 0x8A8575)
        static let textMuted     = Color(hex: 0x9A9483)
        static let kanaPattern   = Color(hex: 0x9A957A)

        static let blue       = Color(hex: 0x1E7BFF)
        static let blueLight  = Color(hex: 0x4F99FF)
        static let blueBg     = Color(hex: 0xDCEBFF)
        static let orange     = Color(hex: 0xFF8A3C)
        static let orangeLite = Color(hex: 0xFFA867)
        static let orangeBg   = Color(hex: 0xFFE6D1)

        static let success     = Color(hex: 0x34C759)
        static let successSoft = Color(hex: 0x34C15E)
        static let successBg   = Color(hex: 0xE7F7EC)
        static let successBrd  = Color(hex: 0xBFE5CB)
        static let danger      = Color(hex: 0xFF5C5C)
        static let dangerBg    = Color(hex: 0xFFE8E8)
        static let dangerBrd   = Color(hex: 0xF8C7C7)

        static let card     = Color.white
        static let ringBg   = Color(hex: 0xEFE8CE)
        static let stepperBg = Color(hex: 0xEFEADA)
        static let toggleOff = Color(hex: 0xE3DEC8)

        static let guideLine = Color(hex: 0xE8E4D0)
        static let chevron   = Color(hex: 0xB8B5A8)
    }

    enum F {
        static let display   = Font.system(size: 44, weight: .black, design: .rounded)
        static let heroScore = Font.system(size: 36, weight: .black, design: .rounded)
        static let romaji    = Font.system(size: 68, weight: .black, design: .rounded)
        static let section   = Font.system(size: 22, weight: .heavy, design: .rounded)
        static let cardTitle = Font.system(size: 19, weight: .bold, design: .rounded)
        static let body      = Font.system(size: 16, weight: .medium)
        static let caption   = Font.system(size: 13, weight: .medium)
        static let label     = Font.system(size: 12, weight: .semibold)

        /// Glyph display font for kana — system serif falls back to Hiragino/Noto Serif JP on iOS.
        static func kanaDisplay(size: CGFloat) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
    }
}

// MARK: - Shadows

extension View {
    func kgCardShadow(lifted: Bool = false) -> some View {
        shadow(
            color: Color.black.opacity(0.08),
            radius: lifted ? 16 : 10,
            x: 0, y: lifted ? 4 : 2
        )
    }

    func kgPillShadow() -> some View {
        shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    func kgPrimaryShadow() -> some View {
        shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Uppercase label

struct KGLabel: View {
    let text: String
    var color: Color = KG.C.textTertiary

    var body: some View {
        Text(text.uppercased())
            .font(KG.F.label)
            .tracking(0.6)
            .foregroundStyle(color)
    }
}

// MARK: - Kana background (animated pattern overlay)

struct KanaBackground: View {
    var body: some View {
        ZStack {
            KG.C.bgCream
                .ignoresSafeArea()

            Image("KanaBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.9)

            LinearGradient(
                colors: [KG.C.bgCream.opacity(0.15), KG.C.bgCream.opacity(0.45)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Pill circle button (settings / close)

struct PillIconButton: View {
    let systemImage: String
    var size: CGFloat = 44
    var iconSize: CGFloat = 18
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(Color(hex: 0x4A4A4A))
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().fill(Color.white.opacity(0.55)))
                )
                .kgPillShadow()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Primary/secondary/success/danger button

enum KGButtonVariant {
    case primary, secondary, success, danger

    var bg: Color {
        switch self {
        case .primary:   return KG.C.textPrimary
        case .secondary: return .white
        case .success:   return KG.C.successSoft
        case .danger:    return KG.C.danger
        }
    }

    var fg: Color {
        self == .secondary ? KG.C.textPrimary : .white
    }

    var border: Color? {
        self == .secondary ? KG.C.dividerHard : nil
    }
}

struct KGButton<Content: View>: View {
    let variant: KGButtonVariant
    var expand: Bool = true
    var disabled: Bool = false
    var action: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                content()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(variant.fg)
            .frame(maxWidth: expand ? .infinity : nil)
            .frame(height: 52)
            .padding(.horizontal, expand ? 0 : 20)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(variant.bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(variant.border ?? .clear, lineWidth: 1)
            )
            .opacity(disabled ? 0.4 : 1)
            .modifier(KGButtonPressable(isPrimary: variant == .primary))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}

private struct KGButtonPressable: ViewModifier {
    let isPrimary: Bool
    func body(content: Content) -> some View {
        if isPrimary {
            content.kgPrimaryShadow()
        } else {
            content.shadow(color: Color.black.opacity(0.06), radius: 1.5, x: 0, y: 1)
        }
    }
}
