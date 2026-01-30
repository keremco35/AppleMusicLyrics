import Foundation

public struct LRCParser {
    public init() {}

    public func parse(lrcContent: String) -> Lyrics {
        var lines: [LyricLine] = []
        let regex = try! NSRegularExpression(pattern: "\\[(\\d{2}):(\\d{2})\\.(\\d{2,3})\\](.*)")

        let plainLines = lrcContent.components(separatedBy: .newlines)

        for line in plainLines {
            let nsString = line as NSString
            let results = regex.matches(in: line, range: NSRange(location: 0, length: nsString.length))

            for result in results {
                let minStr = nsString.substring(with: result.range(at: 1))
                let secStr = nsString.substring(with: result.range(at: 2))
                let msStr = nsString.substring(with: result.range(at: 3))
                let content = nsString.substring(with: result.range(at: 4)).trimmingCharacters(in: .whitespacesAndNewlines)

                if let min = Double(minStr), let sec = Double(secStr), let ms = Double(msStr) {
                    let msValue = msStr.count == 2 ? ms / 100.0 : ms / 1000.0
                    let time = (min * 60) + sec + msValue
                    lines.append(LyricLine(time: time, content: content))
                }
            }
        }

        lines.sort { $0.time < $1.time }
        return Lyrics(lines: lines, isSynced: !lines.isEmpty)
    }
}
