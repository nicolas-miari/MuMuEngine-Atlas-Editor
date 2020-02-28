//
//  TestDataExporting.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/20.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 - precondition: `outputDirectory` is a directory URL to which the app has
 access under the restrictions of the sandbpx (e.g., was obtained through user
 input via an `NSOpenPanel`)
 */
func writeRandomImages(
    to outputDirectory: URL,
    countRange: ClosedRange<Int>,
    widthRange: ClosedRange<Int>,
    heightRange: ClosedRange<Int>,
    scaleFactor: CGFloat) throws {

    let count = Int.random(in: countRange)

    let numberOfDigits = "\(count)".count

    let hueRange = CGFloat(0.0) ... CGFloat(1.0)
    let brightnessRange = CGFloat(0.5) ... CGFloat(1.0)

    let scaleSuffix: String = {
        if scaleFactor == 1.0 {
            return ""
        }
        return "@\(Int(scaleFactor))x"
    }()

    for index in 0 ..< count {
        let width = Int.random(in: widthRange) * Int(scaleFactor)
        let height = Int.random(in: heightRange) * Int(scaleFactor)

        let size = NSSize(width: width, height: height)
        let hue = CGFloat.random(in: hueRange)
        let brigtness = CGFloat.random(in: brightnessRange)
        let color = NSColor(calibratedHue: hue, saturation: 1, brightness: brigtness, alpha: 1.0)

        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 8 * width,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            )!

        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: CGSize(width: width, height: height)))

        let cgImage = context.makeImage()!

        let fileName = String(format: "%0\(numberOfDigits)d\(scaleSuffix).png", index)

        let fileURL = outputDirectory.appendingPathComponent(fileName)

        let rep = NSBitmapImageRep(cgImage: cgImage)
        rep.size = size

        guard let pngData = rep.representation(using: .png, properties: [:]) else {
            throw NSError(localizedDescription: "Failed to generate PNG representation of random image")
        }
        try pngData.write(to: fileURL)
    }
}
