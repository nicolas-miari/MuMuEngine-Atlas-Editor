//
//  CGImage+Extensions.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/27.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGImage {

    func pngData() throws -> Data {

        guard let imageData = CFDataCreateMutable(nil, 0) else {
            throw NSError(localizedDescription: "Failed to create CFMutableData")
        }
        guard let destination = CGImageDestinationCreateWithData(imageData, kUTTypePNG, 1, nil) else {
            throw NSError(localizedDescription: "Failed to create CGImageDestination")
        }
        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw NSError(localizedDescription: "Failed to finalize CGImageDestination")
        }
        return (imageData as Data)
    }
}
