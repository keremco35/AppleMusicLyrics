import SwiftUI
import UIComponents
import PlaybackEngine

struct MainView: View {
    @StateObject private var viewModel = LyricsViewModel()

    var body: some View {
        ZStack {
            AnimatedBackground()
            VStack {
                if let track = viewModel.currentTrack {
                    Text(track.name).font(.title).bold().foregroundColor(.white)
                    Text(track.artist).font(.subheadline).foregroundColor(.gray)
                } else { Text("Waiting...").foregroundColor(.gray) }

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            if let lyrics = viewModel.currentLyrics {
                                ForEach(Array(lyrics.lines.enumerated()), id: \.element.id) { index, line in
                                    LyricLineView(line: line, isActive: index == viewModel.activeLineIndex, isPast: index < viewModel.activeLineIndex)
                                        .id(index)
                                }
                            } else { Text("No Lyrics").foregroundColor(.white.opacity(0.5)) }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.activeLineIndex) { idx in withAnimation { proxy.scrollTo(idx, anchor: .center) } }
                }

                Button(action: { viewModel.togglePiP() }) {
                    Image(systemName: viewModel.isPiPActive ? "pip.exit" : "pip.enter")
                        .font(.title).padding().background(Color.white.opacity(0.2)).clipShape(Circle())
                }
                .padding(.bottom, 40)
            }
            PiPContainerView(manager: viewModel.getPiPManager()).frame(width: 1, height: 1).opacity(0)
        }
    }
}

struct PiPContainerView: UIViewRepresentable {
    let manager: PiPManager
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        manager.setup(in: view)
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
