//
//  Packer.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/08.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

/**
 Packs an array of sources into the specified size. Algorith used is based on
 [this](https://github.com/TeamHypersomnia/rectpack2D#algorithm)
 (Stack Exchange discussion here: https://gamedev.stackexchange.com/q/2829/12721)

 Packing is always perfromed based on units of **points**, _not_ pixels, so that
 all sprites end up aligned on intergal point boundaries. Appropriate conversion
 to pixels is performed only at the moment of **rendering** the packed sprites
 to an image.

 - parameter sources: An array containing all the `Source` instances to be
 packed.

 - parameter canvasSize: The size (in **points**) of the canvas within which the
 sources should be packed.

 - returns: An array containing `Sprite` instances (i.e., sources with a
 position and orientation within the canvas specified).
 */
public func pack(sources: [Source], in canvasSize: CGSize) -> [Sprite] {
    // Sort sources by descening pixel count (i.e., largest first):
    let sortedSources = sources.sorted { $0.pixelCount > $1.pixelCount }

    // Stores all available 'slots', largest first.
    var emptySlots = [CGRect(origin: .zero, size: canvasSize)]

    // Will append each newly packed sprite to this array:
    var result = [Sprite]()

    // Process sources in order:
    for source in sortedSources {
        source.failedToFit = true // (will stay like this unless successfully fitted)

        guard emptySlots.count > 0 else {
            // Run out of bins before fitting all sprites!
            continue
            // (Will still be empty on the next loop round, but if we use break
            // isntead of continue, all subsequent sources will not have a
            // chance to be flagged as 'failed to be packed')
        }

        guard source.pixelCount > 0 else {
            // Skip degenerate images:
            continue
        }

        let originalSize = source.pointSize
        let rotatedSize = originalSize.rotated

        /*
         Search inventory backwards (i.e., try the smaller slots first) for a
         slot that accomodates the source (in either orientation).
         */
        for (reverseIndex, slot) in emptySlots.reversed().enumerated() {
            let fitsUnchanged = originalSize.fits(in: slot)
            let fitsRotated = rotatedSize.fits(in: slot)

            guard fitsUnchanged || fitsRotated else {
                continue // (source does not fit; try next slot)
            }

            // Found an adequate slot; Remove it from inventory:
            let forwardIndex = emptySlots.count - (reverseIndex + 1)
            emptySlots.remove(at: forwardIndex)

            let rotate = !fitsUnchanged && fitsRotated
            let packedSize = rotate ? rotatedSize : originalSize

            // Flag source as 'fitted' and pack source into a new sprite:
            source.failedToFit = false
            let sprite = Sprite(source: source, position: slot.origin, rotated: rotate)
            result.append(sprite)

            // Recycle slot's leftover pieces for fitting subsequent sources:
            let remains = split(sourceRect: slot, byRemovingFromTopLeft: packedSize)
            emptySlots.append(contentsOf: remains)

            // Terminate slot search for this source (proceed to next source):
            break
        }
    }
    return result
}

/**
 Calculates the "pieces" left over after subtracting a top-left aligned
 rectangle of the specified size from the passed source rectangle.

 - Returns:
 - An empty array if the size removed is greater than or equal to the size of `sourceRect`.
 - An array containing one rect if either width or height match.
 - An array containing two rects if both width and height to remove are
 smaller than the size of `sourceRect`, sorted by descending area.
 */
func split(sourceRect: CGRect, byRemovingFromTopLeft sizeToRemove: CGSize) -> [CGRect] {
    guard sizeToRemove.fits(in: sourceRect) else {
        return []
    }

    if sizeToRemove == sourceRect.size {
        // Perfect fit - no leftovers:
        return []
    }

    if sizeToRemove.width == sourceRect.width {
        // [A] Remove full-width top, bottom remains:

        let result = CGRect(
            x: sourceRect.origin.x,
            y: sourceRect.origin.y +  sizeToRemove.height,
            width: sourceRect.width,
            height: sourceRect.height - sizeToRemove.height)
        return [result]

    } else if sizeToRemove.height == sourceRect.height {
        // [B] Remove full-height left side, right side remains:

        let result = CGRect(
            x: sourceRect.origin.x + sizeToRemove.width,
            y: sourceRect.origin.y,
            width: sourceRect.width - sizeToRemove.width,
            height: sourceRect.height)
        return [result]
    } else {
        // [C] Remove top-left corner; two pieces remain.

        /*
         Split the remaining "L" shaped region so that the resulting parts are
         as close to square as possible (avoid extremely "thin" rectangles). To
         acieve that, we try both partitions and compare overall aspect ratios.
         */

        // First Partition Pair: Top-Right and Full-width Bottom
        let topRight = CGRect(
            x: sourceRect.origin.x + sizeToRemove.width,
            y: sourceRect.origin.y,
            width: sourceRect.width - sizeToRemove.width,
            height: sizeToRemove.height)

        let bottom = CGRect(
            x: sourceRect.origin.x,
            y: sourceRect.origin.y +  sizeToRemove.height,
            width: sourceRect.width,
            height: sourceRect.height - sizeToRemove.height)

        let topRightAspect = topRight.landscapeAspectRatio
        let bottomAspect = bottom.landscapeAspectRatio

        // Second Partition Pair: Bottom-Left and Full-height Right:
        let right = CGRect(
            x: sourceRect.origin.x + sizeToRemove.width,
            y: sourceRect.origin.y,
            width: sourceRect.width - sizeToRemove.width,
            height: sourceRect.height)

        let bottomLeft = CGRect(
            x: sourceRect.origin.x,
            y: sourceRect.origin.y +  sizeToRemove.height,
            width: sizeToRemove.width,
            height: sourceRect.height - sizeToRemove.height)

        let rightAspect = right.landscapeAspectRatio
        let bottomLeftASpect = bottomLeft.landscapeAspectRatio

        // Return the pair which has an overall smaller aspect ratio:
        let smallerPair: [CGRect] = {
            if (topRightAspect * bottomAspect) < (rightAspect * bottomLeftASpect) {
                return [topRight, bottom]
            } else {
                return [right, bottomLeft]
            }
        }()

        // ...sorted (smaller rect last):
        return smallerPair.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.area > rhs.area
        })
    }
}

// MARK: - CoreGraphics Extensions (Paclking-specific; keep private unless needed elsewhere)
