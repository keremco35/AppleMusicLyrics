import Foundation
import CoreVideo
import CoreText
import CoreGraphics
import UIKit

public class PiPRenderer {
    private let width = 1920
    private let height = 1080
    public init() {}

    public func render(text: String, nextLine: String?, progress: Double) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attrs as CFDictionary, &pixelBuffer)
        guard let buffer = pixelBuffer else { return nil }
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: width, height: height,
                                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let ctx = context else { return nil }

        ctx.setFillColor(UIColor.black.cgColor)
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        drawText(ctx: ctx, text: text, isMain: true)
        if let next = nextLine { drawText(ctx: ctx, text: next, isMain: false) }
        ctx.setFillColor(UIColor.systemPink.cgColor)
        ctx.fill(CGRect(x: 0, y: height - 20, width: Int(Double(width) * progress), height: 20))
        return buffer
    }

    private func drawText(ctx: CGContext, text: String, isMain: Bool) {
        let fontSize: CGFloat = isMain ? 120 : 60
        let yPos: CGFloat = isMain ? CGFloat(height)/2.0 - 60 : CGFloat(height)/2.0 + 100
        let font = CTFontCreateWithName("Helvetica-Bold" as CFString, fontSize, nil)
        let attrStr = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: isMain ? UIColor.white.cgColor : UIColor.lightGray.cgColor])
        let line = CTLineCreateWithAttributedString(attrStr)
        let bounds = CTLineGetImageBounds(line, ctx)
        ctx.textPosition = CGPoint(x: (CGFloat(width)-bounds.width)/2.0, y: yPos)
        CTLineDraw(line, ctx)
    }
}
