import Foundation

public struct LyricLine: Codable, Equatable, Identifiable {
    public let id: UUID
    public let time: TimeInterval
    public let content: String

    public init(time: TimeInterval, content: String) {
        self.id = UUID()
        self.time = time
        self.content = content
    }
}

public struct Lyrics: Codable, Equatable {
    public let lines: [LyricLine]
    public let isSynced: Bool

    public init(lines: [LyricLine], isSynced: Bool) {
        self.lines = lines
        self.isSynced = isSynced
    }
}

public struct TrackInfo: Codable, Equatable {
    public let name: String
    public let artist: String
    public let album: String?
    public let duration: TimeInterval

    public init(name: String, artist: String, album: String? = nil, duration: TimeInterval) {
        self.name = name
        self.artist = artist
        self.album = album
        self.duration = duration
    }
}
