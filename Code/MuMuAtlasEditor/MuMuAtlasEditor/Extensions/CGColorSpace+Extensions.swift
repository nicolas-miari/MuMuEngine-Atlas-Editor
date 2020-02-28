//
//  CGColorSpace+Extensions.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/26.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import CoreGraphics

public extension CGColorSpace {

    var prettyName: String {
        guard let name = name else {
            return "Unknown Color Space"
        }
        switch name {
            // All constants listed in:
            // https://developer.apple.com/documentation/coregraphics/cgcolorspace

        case CGColorSpace.acescgLinear:
            return "ACEScg"

        case CGColorSpace.adobeRGB1998:
            return "Adobe RGB (1998)"

        case CGColorSpace.dcip3:
            return "DCI P3"

        case CGColorSpace.displayP3:
            return "Display P3"

        case CGColorSpace.extendedGray:
            // (Much more than 50 shades I pressume...)
            return "Extended Gray"

        case CGColorSpace.extendedLinearGray:
            return "Extended Linear Gray"

        case CGColorSpace.extendedLinearSRGB:
            return "Extended Linear sRGB"

        case CGColorSpace.extendedSRGB:
            return "Extended sRGB"

        case CGColorSpace.genericCMYK:
            return "Generic CMYK"

        case CGColorSpace.genericXYZ:
            return "Generic XYZ"

        case CGColorSpace.itur_2020:
            return "ITU-R Recommendation BT.2020"

        case CGColorSpace.itur_709:
            return "ITU-R Recommendation BT.709"

        case CGColorSpace.linearGray:
            return "Linear Gray"

        case CGColorSpace.linearSRGB:
            return "Linear sRGB"

        case CGColorSpace.rommrgb:
            return "ROMM RGB"

        case CGColorSpace.sRGB:
            return "sRGB"

        default:
            return "Unknown Color Space"
            // (not sure how to cover this: attempting to initialize CGColorSpace with a bogus name gives nil)
        }
    }
}
