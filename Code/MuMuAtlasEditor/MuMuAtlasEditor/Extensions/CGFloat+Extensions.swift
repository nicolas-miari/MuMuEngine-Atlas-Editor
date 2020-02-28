//
//  CGFloat+Extensions.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/20.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

public extension CGFloat {
    /**
     Scans the argument for a pattern like `@%fx` (e.g., @2x, @3x) and sets
     itself to the numerical value therein, or 1 if none is found.
     */
    init(scaleFactorIn text: String) {
        let deletingExtension = (text as NSString).deletingPathExtension

        let components = deletingExtension.components(separatedBy: "@")
        guard components.count > 1, let lastComponent = components.last else {
            // No '@' means no scale factor specifier; Default to 1.0:
            self = 1
            return
        }
        let numberString = lastComponent.replacingOccurrences(of: "x", with: "")
        self = CGFloat(Float(numberString) ?? 1.0)
    }
}
