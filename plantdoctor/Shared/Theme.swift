import SwiftUI

enum Theme {
    static let leaf = Color(red: 0x2E / 255, green: 0x7D / 255, blue: 0x32 / 255)
    static let leafLight = Color(red: 0xC8 / 255, green: 0xE6 / 255, blue: 0xC9 / 255)
    static let soil = Color(red: 0x5D / 255, green: 0x40 / 255, blue: 0x37 / 255)
    static let cream = Color(red: 0xFB / 255, green: 0xF7 / 255, blue: 0xEE / 255)
}

struct LeafButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Theme.leaf)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
