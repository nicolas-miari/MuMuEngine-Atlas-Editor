//
//  Renderer.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/12.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

// MARK: - Public Interface

public func renderPreview(sprites: [Sprite], canvasSize: CGSize, scaleFactor: CGFloat, drawOutlines: Bool) throws -> CGImage {
    let options: RenderOptions = drawOutlines ? [.drawOutlines, .drawBackground] : [.drawBackground]
    return try render(sprites: sprites, canvasSize: canvasSize, scaleFactor: scaleFactor, options: options)
}

public func renderTexture(sprites: [Sprite], canvasSize: CGSize, scaleFactor: CGFloat) throws -> CGImage {
    return try render(sprites: sprites, canvasSize: canvasSize, scaleFactor: scaleFactor, options: [])
}

// MARK: - Supporting Private Code

private struct RenderOptions: OptionSet {
    let rawValue: Int

    static let drawOutlines = RenderOptions(rawValue: 1 << 0)
    static let drawBackground = RenderOptions(rawValue: 1 << 1)
}

private func render(sprites: [Sprite], canvasSize: CGSize, scaleFactor: CGFloat, options: RenderOptions) throws -> CGImage {
    let contextSize = CGSize(width: scaleFactor * canvasSize.width, height: scaleFactor * canvasSize.height)
    guard let context = CGContext(
        data: nil,
        width: Int(contextSize.width),
        height: Int(contextSize.height),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw NSError(localizedDescription: "Failed to Create Core Graphics Context")
    }

    let drawOutlines = options.contains(.drawOutlines)
    let drawBackground = options.contains(.drawBackground)

    let lineWidth: CGFloat = 1 * scaleFactor

    if drawOutlines {
        context.setStrokeColor(NSColor.systemBlue.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineJoin(.miter)
        context.setMiterLimit(100)
        context.setLineCap(.square)

        let fillColor = NSColor.systemBlue.withAlphaComponent(0.5)
        context.setFillColor(fillColor.cgColor)
    }

    if drawBackground {
        context.drawCheckerboard(
            in: CGRect(origin: .zero, size: contextSize),
            firstColor: NSColor(deviceWhite: 0.95, alpha: 1).cgColor,
            secondColor: NSColor(deviceWhite: 0.80, alpha: 1).cgColor,
            cellSide: 64 * Int(scaleFactor)
        )
    }

    sprites.forEach { (sprite) in
        if sprite.rotated {

            context.saveGState()

            let nativeSize = sprite.nativeSize.scaledBy(scaleFactor)
            let targetRect = sprite.targetRect.scaledBy(scaleFactor)

            let targetCenter = CGPoint(x: targetRect.midX, y: targetRect.midY)

            context.translateBy(x: targetCenter.x, y: targetCenter.y)
            context.rotate(by: 0.5*CGFloat.pi)
            context.translateBy(x: -0.5*nativeSize.width, y: -0.5*nativeSize.height)

            if drawOutlines {
                let rect = CGRect(origin: .zero, size: nativeSize).insetBy(lineWidth/2)
                context.fill(rect)
            }
            context.draw(sprite.sourceImage, in: CGRect(origin: .zero, size: nativeSize))

            if drawOutlines {
                let rect = CGRect(origin: .zero, size: nativeSize).insetBy(lineWidth/2)
                context.stroke(rect)
            }
            context.restoreGState()
        } else {
            let targetRect = sprite.targetRect.scaledBy(scaleFactor)

            if drawOutlines {
                let rect = targetRect.insetBy(lineWidth/2)
                context.fill(rect)
            }
            context.draw(sprite.sourceImage, in: targetRect)
            if drawOutlines {
                let rect = targetRect.insetBy(lineWidth/2)
                context.stroke(rect)
            }
        }
    }
    guard let image = context.makeImage() else {
        throw NSError(localizedDescription: "Failed to obtain CGContext image")
    }
    return image
}

// MARK: - Core Graphics Extensions (Renderer-Specific)

private extension CGContext {

    func drawCheckerboard(in rect: CGRect, firstColor: CGColor, secondColor: CGColor, cellSide: Int) {
        saveGState()

        // 1. Fill whole rect with one color:
        setFillColor(firstColor)
        fill(CGRect(origin: .zero, size: AppConfiguration.defaultCanvasSize))

        // 2. Draw alternating squares in the other color:
        setFillColor(secondColor)

        let numColumns = Int(rect.width) / cellSide
        let numRows = Int(rect.height) / cellSide
        let cellSize = CGSize(width: cellSide, height: cellSide)
        for row in 0 ..< numRows {
            for col in 0 ..< numColumns where (row + col) % 2 == 0 {
                let cellOrigin = CGPoint(
                    x: rect.origin.x + CGFloat(cellSide * col),
                    y: rect.origin.y + CGFloat(cellSide * row)
                )
                fill(CGRect(origin: cellOrigin, size: cellSize))
            }
        }
        restoreGState()
    }
}
