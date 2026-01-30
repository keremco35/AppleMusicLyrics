import SwiftUI

public struct AnimatedBackground: View {
    @State private var animate = false
    public init() {}
    public var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            Circle().fill(Color.purple.opacity(0.4)).frame(width: 300, height: 300).blur(radius: 60)
                .offset(x: animate ? -100 : 100, y: animate ? -100 : 100)
            Circle().fill(Color.blue.opacity(0.4)).frame(width: 300, height: 300).blur(radius: 60)
                .offset(x: animate ? 100 : -100, y: animate ? 100 : -50)
        }
        .animation(Animation.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animate)
        .onAppear { animate.toggle() }
        .edgesIgnoringSafeArea(.all)
    }
}
