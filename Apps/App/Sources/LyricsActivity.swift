import ActivityKit
import WidgetKit
import SwiftUI

struct LyricsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentLine: String
        var nextLine: String
    }
    var trackName: String
}

struct LyricsActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LyricsAttributes.self) { context in
            VStack {
                Text(context.state.currentLine).font(.headline).foregroundColor(.white)
                Text(context.state.nextLine).font(.subheadline).foregroundColor(.gray)
            }
            .padding().activityBackgroundTint(Color.black.opacity(0.8))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) { Text("🎵") }
                DynamicIslandExpandedRegion(.trailing) { Text(context.attributes.trackName).font(.caption) }
                DynamicIslandExpandedRegion(.bottom) { Text(context.state.currentLine).multilineTextAlignment(.center) }
            } compactLeading: { Text("🎵") } compactTrailing: { Text(context.state.currentLine.prefix(10)) } minimal: { Text("🎵") }
        }
    }
}
