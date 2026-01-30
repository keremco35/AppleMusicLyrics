import SwiftUI
import LyricsEngine

public struct LyricLineView: View {
    let line: LyricLine
    let isActive: Bool
    let isPast: Bool

    public init(line: LyricLine, isActive: Bool, isPast: Bool) {
        self.line = line
        self.isActive = isActive
        self.isPast = isPast
    }

    public var body: some View {
        Text(line.content)
            .font(.system(size: isActive ? 32 : 24, weight: isActive ? .bold : .medium, design: .rounded))
            .foregroundColor(isActive ? .white : (isPast ? .gray.opacity(0.5) : .gray))
            .scaleEffect(isActive ? 1.05 : 1.0)
            .blur(radius: isPast ? 0.5 : 0)
            .animation(.spring(), value: isActive)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
