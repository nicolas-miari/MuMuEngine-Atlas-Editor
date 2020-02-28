//
//  CGGeometry+Extensions.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/19.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import CoreGraphics

// MARK: - CGPoint

public extension CGPoint {
    func scaledBy(_ factor: CGFloat) -> CGPoint {
        return CGPoint(x: factor * x, y: factor * y)
    }
}

// MARK: - CGSize

public extension CGSize {
    /**
     The absolute value of factor is always used to avoid a negative size.
     */
    func scaledBy(_ factor: CGFloat) -> CGSize {
        return CGSize(width: abs(factor) * width, height: abs(factor) * height)
    }

    /**
     Returns `true` iff both the receiver's width and size are less than or
     equal to those of `otherSize`.
     */
    func fits(in otherSize: CGSize) -> Bool {
        return (width <= otherSize.width) && (height <= otherSize.height)
    }

    /**
     Returns `true` iff both the receiver's width and size are less than or
     equal to those of `rect.size`.
     */
    func fits(in rect: CGRect) -> Bool {
        return fits(in: rect.size)
    }

    /**
     Swaps width and height (i.e., the original size 'rotated' by a right
     angle).
     */
    var rotated: CGSize {
        return CGSize(width: height, height: width)
    }

    /**
     Returns the ratio of longer side to shorter side (i.e., width/height after
     a potential rotation to 'landscape', so that the new width is the longer
     side). Used to determine how "thin" a size is regardless of orientation.
     */
    var landscapeAspectRatio: CGFloat {
        if width >= height {
            return width / height
        } else {
            return height / width
        }
    }
}

// MARK: - CGRect

public extension CGRect {
    /**
     Returns `true` iff both the receiver's width and size are less than or
     equal to those of `size`.
     */
    func fits(in otherSize: CGSize) -> Bool {
        return size.fits(in: otherSize)
    }

    /**
     Returns `true` iff both the receiver's width and size are less than or
     equal to those of `otherRect.size`.
     */
    func fits(in otherRect: CGRect) -> Bool {
        return fits(in: otherRect.size)
    }

    /**
     The area covered by the receiver (i.e., `width` x `height`).
     */
    var area: CGFloat {
        return width * height
    }

    /**
     Returns the ratio of longer side to shorter side (i.e., width/height after
     a potential rotation to 'landscape', so that the new width is the longer
     side). Used to determine how "thin" a rectangle is, regardless of its
     orientation.
     */
    var landscapeAspectRatio: CGFloat {
        return size.landscapeAspectRatio
    }

    /**
     Returns a scaled copy of the receiver: all components of both `origin` and
     `size` are multiplied by `factor`.
     */
    func scaledBy(_ factor: CGFloat) -> CGRect {
        return CGRect(origin: origin.scaledBy(factor), size: size.scaledBy(factor))
    }

    /**
     Returns a rectangle inset into the receiver by the specified margin.
     For example, if the receiver is `((0, 1), (10, 12))` and you call this
     method with a margin of `2`, the returned rectangle will be
     `((2, 3), (6, 8))`: The margin value gets added to both the `x` and `y`
     components of the `origin`, and twice that (in this case, `4`) gets
     subtracted from both the `width` and `height`.

     - parameter margin: The margin by which the new rectangle is inset
     (inscribed) within the receiver.
     */
    func insetBy(_ margin: CGFloat) -> CGRect {
        return CGRect(
            origin: CGPoint(x: origin.x + margin, y: origin.y + margin),
            size: CGSize(width: width - 2*margin, height: height - 2*margin)
        )
    }
}
