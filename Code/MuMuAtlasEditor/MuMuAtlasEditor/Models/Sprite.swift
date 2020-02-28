//
//  Sprite.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/14.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 Represents the result of fitting one asset library item at a specific position of the atlas canvas.

 An array of instances of this struct (one per source packed) effectively constitutes an arrangement
 (result) of the atlas packing process, and thus contains enough information to render the output
 texture of the atlas.
 */
public struct Sprite {

    /**
     Name of the sprite, based on the name of the source library asset. This is the name that will be
     used by the game runtime to instantiate the sprite from the atlas.
     */
    let name: String

    /**
     Whether the original source bitmap must be rotated 90 degress to fit in the atlas.
     */
    let rotated: Bool

    /**
     If `true`, the sprite can be rendered with alpha blending disabled.
     */
    var isOpaque: Bool {
        return source.isOpaque
    }

    /**
     The source bitmap, in its original (i.e. always non-rotated) orientation.
     */
    var sourceImage: CGImage {
        return source.image
    }
    private let source: Source

    /**
     Size of the source asset library image in its original (i.e. always non-rotated) orientation. Units
     are in points.
     */
    var nativeSize: CGSize {
        if rotated {
            return targetRect.size.rotated
        } else {
            return targetRect.size
        }
    }

    /**
     The destination rect where the bitmap will be rendered (if rotated is `true`, width and height are
     swapped with respect to those of the source bitmap). Units are in points.
     */
    let targetRect: CGRect

    /**
     - parameter source: The library asset to pack.
     - parameter position: Location within the canvas, in points.
     - parameter rotated: A boolean indicating whether the source's image was packed in its original
     orientation (`false`) or needed to be rotated by 90 degrees (`true`).
     */
    init(source: Source, position: CGPoint, rotated: Bool) {
        self.name = source.name
        self.source = source
        let size = source.pointSize

        if !rotated {
            self.targetRect = CGRect(origin: position, size: size)
        } else {
            self.targetRect = CGRect(origin: position, size: size.rotated)
        }
        self.rotated = rotated
    }
}
