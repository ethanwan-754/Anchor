import SwiftUI



extension Color {
    init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        h = h.hasPrefix("#") ? String(h.dropFirst()) : h
        guard h.count == 6, let rgb = UInt64(h, radix: 16) else {
            self = .gray; return
        }
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        h = h.hasPrefix("#") ? String(h.dropFirst()) : h
        guard h.count == 6, let rgb = UInt64(h, radix: 16) else { return nil }
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}


enum AnchorDesign {
    
    static let primary   = Color(hex: "#0A0E27")
    static let accent    = Color(hex: "#6C63FF")
    static let accentAlt = Color(hex: "#00D4AA")
    static let surface   = Color(hex: "#F2F3FF")    

    static let titleFont   = Font.system(size: 22, weight: .black, design: .rounded)
    static let headingFont = Font.system(size: 17, weight: .bold, design: .rounded)
    static let bodyFont    = Font.system(size: 15, weight: .regular)
    static let captionFont = Font.system(size: 12, weight: .medium)
    static let monoFont    = Font.system(size: 13, weight: .semibold, design: .monospaced)

    static let cardRadius: CGFloat    = 18
    static let chipRadius: CGFloat    = 12
    static let buttonRadius: CGFloat  = 16

    static func cardShadow() -> some View {
        Color.black.opacity(0.08)
    }
}


struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AnchorDesign.cardRadius))
            .shadow(color: .black.opacity(0.07), radius: 8, y: 3)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardStyle(padding: padding))
    }
}


struct SectionLabel: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.secondary)
            .tracking(1.5)
    }
}
