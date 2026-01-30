import Foundation
import AVKit
import AVFoundation

public class PiPManager: NSObject, AVPictureInPictureControllerDelegate, AVPictureInPictureSampleBufferPlaybackDelegate {
    private var pipController: AVPictureInPictureController?
    private var displayLayer: AVSampleBufferDisplayLayer?
    private let renderer = PiPRenderer()
    private var timer: Timer?

    public var currentLine: String = ""
    public var nextLine: String = ""
    public var progress: Double = 0.0

    public override init() { super.init() }

    public func setup(in view: UIView) {
        let displayLayer = AVSampleBufferDisplayLayer()
        displayLayer.frame = .zero
        view.layer.addSublayer(displayLayer)
        self.displayLayer = displayLayer
        if AVPictureInPictureController.isPictureInPictureSupported() {
            let source = AVPictureInPictureController.ContentSource(sampleBufferDisplayLayer: displayLayer, playbackDelegate: self)
            pipController = AVPictureInPictureController(contentSource: source)
            pipController?.delegate = self
            pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        }
    }

    public func start() {
        pipController?.startPictureInPicture()
        timer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { [weak self] _ in self?.enqueueFrame() }
    }

    public func stop() {
        pipController?.stopPictureInPicture()
        timer?.invalidate()
    }

    private func enqueueFrame() {
        guard let layer = displayLayer, layer.status != .failed,
              let cvBuffer = renderer.render(text: currentLine, nextLine: nextLine, progress: progress) else { return }

        var sampleBuffer: CMSampleBuffer?
        var timingInfo = CMSampleTimingInfo(duration: CMTime.invalid, presentationTimeStamp: CMClockGetTime(CMClockGetHostTimeClock()), decodeTimeStamp: CMTime.invalid)
        var desc: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: cvBuffer, formatDescriptionOut: &desc)
        guard let fd = desc else { return }

        CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: cvBuffer, formatDescription: fd, sampleTiming: &timingInfo, sampleBufferOut: &sampleBuffer)
        if let sb = sampleBuffer, layer.isReadyForMoreMediaData { layer.enqueue(sb) }
    }

    public func pictureInPictureController(_ pip: AVPictureInPictureController, setPlaying playing: Bool) {}
    public func pictureInPictureControllerTimeRangeForPlayback(_ pip: AVPictureInPictureController) -> CMTimeRange { .init(start: .zero, duration: .positiveInfinity) }
    public func pictureInPictureControllerIsPlaybackPaused(_ pip: AVPictureInPictureController) -> Bool { false }
    public func pictureInPictureController(_ pip: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion completionHandler: @escaping () -> Void) { completionHandler() }
    public func pictureInPictureController(_ pip: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {}
}
