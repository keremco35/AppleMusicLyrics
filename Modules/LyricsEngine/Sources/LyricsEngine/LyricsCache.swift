import Foundation

public class LyricsCache {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    public init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        self.cacheDirectory = urls[0].appendingPathComponent("LyricsCache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    public func save(lyrics: Lyrics, for track: TrackInfo) {
        let key = "\(track.artist)-\(track.name)".addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "unknown"
        let url = cacheDirectory.appendingPathComponent(key + ".json")
        do {
            let data = try JSONEncoder().encode(lyrics)
            try data.write(to: url)
        } catch { print("Cache error: \(error)") }
    }

    public func get(for track: TrackInfo) -> Lyrics? {
        let key = "\(track.artist)-\(track.name)".addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "unknown"
        let url = cacheDirectory.appendingPathComponent(key + ".json")
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return try? JSONDecoder().decode(Lyrics.self, from: Data(contentsOf: url))
    }
}
