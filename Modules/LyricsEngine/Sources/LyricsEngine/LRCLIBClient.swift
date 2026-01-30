import Foundation

public enum LyricsError: Error {
    case notFound
    case networkError(Error)
}

struct LRCLIBResponse: Codable {
    let syncedLyrics: String?
    let plainLyrics: String?
    let instrumental: Bool
}

public class LRCLIBClient {
    private let baseURL = URL(string: "https://lrclib.net/api")!

    public init() {}

    public func fetchLyrics(for track: TrackInfo) async throws -> Lyrics {
        if let lyrics = try? await fetchSpecific(track: track) { return lyrics }

        let cleanedName = cleanTrackName(track.name)
        let cleanedTrack = TrackInfo(name: cleanedName, artist: track.artist, duration: track.duration)
        if let lyrics = try? await fetchSpecific(track: cleanedTrack) { return lyrics }

        throw LyricsError.notFound
    }

    private func cleanTrackName(_ name: String) -> String {
        let regex = try! NSRegularExpression(pattern: "\\s*\\([^)]*\\)", options: .caseInsensitive)
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex.stringByReplacingMatches(in: name, options: [], range: range, withTemplate: "")
    }

    private func fetchSpecific(track: TrackInfo) async throws -> Lyrics {
        var components = URLComponents(url: baseURL.appendingPathComponent("get"), resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "track_name", value: track.name),
            URLQueryItem(name: "artist_name", value: track.artist),
            URLQueryItem(name: "duration", value: String(Int(track.duration)))
        ]
        if let album = track.album { components.queryItems?.append(URLQueryItem(name: "album_name", value: album)) }

        guard let url = components.url else { throw LyricsError.notFound }
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw LyricsError.notFound }
        let decoded = try JSONDecoder().decode(LRCLIBResponse.self, from: data)

        if let synced = decoded.syncedLyrics {
            return LRCParser().parse(lrcContent: synced)
        } else if let plain = decoded.plainLyrics {
            return Lyrics(lines: [LyricLine(time: 0, content: plain)], isSynced: false)
        }
        throw LyricsError.notFound
    }
}
