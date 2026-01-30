# LyricFlow - iOS Lyrics Engine

A senior-level iOS application featuring real-time lyrics synchronization, PiP support, CarPlay integration, and an advanced offline caching system.

## Features
- **Real-time Lyrics**: Fetches from LRCLIB.net.
- **Picture-in-Picture**: Custom `AVSampleBufferDisplayLayer` renderer for lyrics overlay.
- **Offline Cache**: JSON-based caching for offline access.
- **CarPlay**: Read-only lyrics mode.
- **Live Activity**: Dynamic Island support.
- **Heavy Assets**: Includes strategies for 100MB+ IPA size (via dummy assets).

## Architecture
- **Modules**:
  - `LyricsEngine`: Core logic, networking, parsing.
  - `PlaybackEngine`: MusicKit wrapper, PiP rendering.
  - `UIComponents`: Reusable SwiftUI views.
- **App**:
  - MVVM pattern (`LyricsViewModel`).
  - Coordinator-style navigation (implied).

## Build Instructions
1. **Install Dependencies**:
   ```bash
   brew install xcodegen
   ```
2. **Generate Project**:
   ```bash
   xcodegen generate
   ```
3. **Generate Assets** (Required for 100MB target):
   ```bash
   ./Scripts/generate_assets.sh
   ```
4. **Build**:
   Open `LyricFlow.xcodeproj` and build for your target device.

## CI/CD
The project uses GitHub Actions (`.github/workflows/ios-release.yml`) to:
1. Generate the project.
2. create dummy assets.
3. Build an unsigned IPA.
4. Verify IPA size is > 100MB.
5. Create a GitHub Release.

## License
MIT
