import SwiftUI
import Combine
import LyricsEngine
import PlaybackEngine
import MusicKit
import ActivityKit

@MainActor
class LyricsViewModel: ObservableObject {
    @Published var currentLyrics: Lyrics?
    @Published var activeLineIndex: Int = 0
    @Published var currentTrack: TrackInfo?
    @Published var isPiPActive = false

    private let playbackManager = MusicPlayerManager.shared
    private let lyricsClient = LRCLIBClient()
    private let lyricsCache = LyricsCache()
    private let pipManager = PiPManager()
    private var cancellables = Set<AnyCancellable>()

    // Live Activity
    private var activity: Any?

    init() {
        playbackManager.$currentSong.compactMap { $0 }.removeDuplicates().sink { [weak self] s in self?.handleTrackChange(song: s) }.store(in: &cancellables)
        playbackManager.$currentTime.sink { [weak self] t in self?.updateActiveLine(at: t); self?.updatePiP(at: t) }.store(in: &cancellables)
    }

    private func handleTrackChange(song: Song) {
        let trackInfo = TrackInfo(name: song.title, artist: song.artistName, duration: song.duration ?? 0)
        self.currentTrack = trackInfo
        self.currentLyrics = nil
        self.activeLineIndex = 0
        endActivity()

        Task {
            if let cached = lyricsCache.get(for: trackInfo) {
                self.currentLyrics = cached
                startActivity(track: trackInfo)
                return
            }
            if let lyrics = try? await lyricsClient.fetchLyrics(for: trackInfo) {
                self.currentLyrics = lyrics
                lyricsCache.save(lyrics: lyrics, for: trackInfo)
                startActivity(track: trackInfo)
            }
        }
    }

    private func updateActiveLine(at time: TimeInterval) {
        guard let lyrics = currentLyrics else { return }
        if let idx = lyrics.lines.lastIndex(where: { $0.time <= time }) {
            if activeLineIndex != idx {
                activeLineIndex = idx
                updateActivity()
            }
        }
    }

    private func updatePiP(at time: TimeInterval) {
        guard isPiPActive, let lyrics = currentLyrics else { return }
        pipManager.currentLine = lyrics.lines.indices.contains(activeLineIndex) ? lyrics.lines[activeLineIndex].content : ""
        pipManager.nextLine = lyrics.lines.indices.contains(activeLineIndex + 1) ? lyrics.lines[activeLineIndex + 1].content : ""
        if lyrics.lines.indices.contains(activeLineIndex + 1) {
            let start = lyrics.lines[activeLineIndex].time
            let duration = lyrics.lines[activeLineIndex + 1].time - start
            pipManager.progress = min(max((time - start)/duration, 0), 1)
        }
    }

    func togglePiP() {
        isPiPActive.toggle()
        isPiPActive ? pipManager.start() : pipManager.stop()
    }

    func getPiPManager() -> PiPManager { pipManager }

    // MARK: - Live Activity
    private func startActivity(track: TrackInfo) {
        if #available(iOS 16.1, *) {
            let attributes = LyricsAttributes(trackName: track.name)
            let state = LyricsAttributes.ContentState(currentLine: "Loading...", nextLine: "")
            do {
                let act = try Activity<LyricsAttributes>.request(attributes: attributes, contentState: state, pushType: nil)
                self.activity = act
            } catch { print("Activity Error: \(error)") }
        }
    }

    private func updateActivity() {
        if #available(iOS 16.1, *) {
            guard let act = activity as? Activity<LyricsAttributes>, let lyrics = currentLyrics else { return }
            let current = lyrics.lines.indices.contains(activeLineIndex) ? lyrics.lines[activeLineIndex].content : ""
            let next = lyrics.lines.indices.contains(activeLineIndex + 1) ? lyrics.lines[activeLineIndex + 1].content : ""
            let state = LyricsAttributes.ContentState(currentLine: current, nextLine: next)
            Task { await act.update(using: state) }

            // Post notification for CarPlay
            NotificationCenter.default.post(name: .init("LyricsUpdate"), object: nil, userInfo: ["line": current, "next": next])
        }
    }

    private func endActivity() {
        if #available(iOS 16.1, *) {
            if let act = activity as? Activity<LyricsAttributes> {
                Task { await act.end(dismissalPolicy: .immediate) }
                self.activity = nil
            }
        }
    }
}
