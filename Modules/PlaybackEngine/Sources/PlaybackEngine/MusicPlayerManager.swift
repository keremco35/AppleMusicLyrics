import Foundation
import MusicKit
import Combine

public class MusicPlayerManager: ObservableObject {
    public static let shared = MusicPlayerManager()
    @Published public var currentSong: Song?
    @Published public var isPlaying: Bool = false
    @Published public var currentTime: TimeInterval = 0
    private var timer: Timer?

    public init() {
        Task {
            // Simplified observation for demo
             timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.currentTime = SystemMusicPlayer.shared.playbackTime
                self?.isPlaying = SystemMusicPlayer.shared.state.playbackStatus == .playing

                Task {
                    let queue = SystemMusicPlayer.shared.queue
                    if let entry = queue.currentEntry, case let .song(song) = entry.item {
                        DispatchQueue.main.async {
                            if self?.currentSong?.id != song.id {
                                self?.currentSong = song
                            }
                        }
                    }
                }
            }
        }
    }
}
