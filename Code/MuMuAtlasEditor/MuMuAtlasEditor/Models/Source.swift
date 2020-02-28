//
//  Source.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/13.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 Represents a single entry in the library of assets that can be packed into the current document's atlas.
 Contains image data (pixels) as well as all relevant metadata (display name, size, color space, scale
 factor, etc.).
 */
public final class Source: Equatable {

    public static func == (lhs: Source, rhs: Source) -> Bool {
        return (lhs.name == rhs.name)
    }

    /**
     Sources are referenced by name within the document's atlas. therefore the value of this property
     must be unique within the current document's asset library. The class adopts the Equatable protocol
     and two instances are considered "equal" if and only if they have the same `name`.
     */
    var name: String

    /**
     How many pixels in the image data correspond to one point on screen.
     */
    let scaleFactor: CGFloat

    /**
     The actual pixel data.
     */
    var image: CGImage {
        return imageData!
    }

    private let imageData: CGImage?

    let isOpaque: Bool

    /**
     A flag indicating whether the source is currently scheduled to be packed on the exported atlas. Initially
     set to `true` when first importing a new source from file.
     */
    var isIncluded: Bool = false

    /**
     For comparing sizes of different sources during packing.
     */
    let pixelCount: Int

    /**
     Size (width and height) of the image data, in **pixels**.
     */
    let pixelSize: CGSize

    /**
     Size (width and height) of the image, in **points**. Derived from `pixelSize` and `scaleFactor`.
     */
    let pointSize: CGSize

    /**
     The offset from the image's geometric center (width/2, height/2) that will correspond to the sprite's position
     when drawen onscreen.
     */
    var anchorPoint: CGPoint = .zero

    /**
     Flags whether the source failed to be packed during the last attempt at packing all the library sources marked
     for inclusion. Used for providing a per-source visual feedback of the failure within in the editor's UI.
     */
    var failedToFit: Bool = false

    // MARK: - Inspectable Attributes

    var pointWidth: Int {
        return Int(pixelSize.width / scaleFactor)
    }

    var pointHeight: Int {
        return Int(pixelSize.height / scaleFactor)
    }

    var pixelWidth: Int {
        return Int(pixelSize.width)
    }

    var pixelHeight: Int {
        return Int(pixelSize.height)
    }

    // MARK: - Initialization

    /**
     Initializes a new instance from an image file on disk. Used when imorting a new source into a project.

     - The value of the `name` property is obtained from the file name, after stripping any scale qualifiers (e.g.
     "@2x") and file extensions (e.g., ".png").
     - The value of the `scaleFactor` property is determined from the first scale qualifier (e.g., @2x) found in the
     file's name. If none is found, @1x is assumed.
     */
    init?(contentsOfFile filePath: String) {
        guard let data = FileManager.default.contents(atPath: filePath) else {
            return nil
        }
        guard let representation = NSBitmapImageRep(data: data) else {
            return nil
        }
        self.isOpaque = representation.isOpaque
        guard let image = representation.cgImage else {
            return nil
        }
        self.name = (filePath as NSString).lastPathComponent
        self.imageData = image
        self.pixelCount = (image.width * image.height)
        self.pixelSize = CGSize(width: image.width, height: image.height)
        self.scaleFactor = {
            let fileName = (filePath as NSString).lastPathComponent
            let name = (fileName as NSString).deletingPathExtension
            let components = name.components(separatedBy: "@")
            guard components.count > 1 else {
                return 1
            }
            let integerString = components[1].replacingOccurrences(of: "x", with: "")
            guard let integer = Int(integerString) else {
                return 1
            }
            return CGFloat(integer)
        }()
        self.pointSize = CGSize(width: pixelSize.width / scaleFactor, height: pixelSize.height / scaleFactor)
    }

    /**
     Used for restoring an archived source from within the project document's bundle.
     */
    init(name: String, image: CGImage, scaleFactor: CGFloat? = nil, isOpaque: Bool) {
        self.name = name
        self.imageData = image
        self.pixelCount = (image.width * image.height)

        let pixelSize = CGSize(width: image.width, height: image.height)
        self.pixelSize = pixelSize

        if let scaleFactor = scaleFactor {
            self.scaleFactor = scaleFactor
            self.pointSize = CGSize(width: pixelSize.width / scaleFactor, height: pixelSize.height / scaleFactor)
        } else {
            self.scaleFactor =  CGFloat(scaleFactorIn: name)
            self.pointSize = pixelSize
        }
        self.isOpaque = isOpaque
    }

    /**
     Creates a 'logical' source with name and metric properties only, but no actual bitmap data, for the purpose
     of testing packing alorithms, etc. Accessing the image property of such an isntance will result in a "Nil
     found while unwrapping optional" runtime error.
     - parameter size: The size, in points. Use in concert with `scaleFactor` to create a source with a specific
     pixel size.
     */
    init(name: String, size: CGSize, scaleFactor: CGFloat = 1) {
        self.name = name
        self.imageData = nil
        self.scaleFactor = scaleFactor
        self.pointSize = size
        self.pixelSize = size.scaledBy(scaleFactor)
        self.pixelCount = Int(pointSize.width * pixelSize.height)
        self.isOpaque = true
    }
}
