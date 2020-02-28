//
//  CGColorSpaceTests.swift
//  AtlasEditorTests
//
//  Created by Nicolás Miari on 2019/03/27.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import MuMuAtlasEditor

class CGColorSpaceTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPrettyNames() {

        let prettyNamesNyName: [CFString: String] = [
            CGColorSpace.acescgLinear: "ACEScg",
            CGColorSpace.adobeRGB1998: "Adobe RGB (1998)",
            CGColorSpace.dcip3: "DCI P3",
            CGColorSpace.displayP3: "Display P3",
            CGColorSpace.extendedGray: "Extended Gray",
            CGColorSpace.extendedLinearGray: "Extended Linear Gray",
            CGColorSpace.extendedLinearSRGB: "Extended Linear sRGB",
            CGColorSpace.extendedSRGB: "Extended sRGB",
            CGColorSpace.genericCMYK: "Generic CMYK",
            CGColorSpace.genericXYZ: "Generic XYZ",
            CGColorSpace.itur_2020: "ITU-R Recommendation BT.2020",
            CGColorSpace.itur_709: "ITU-R Recommendation BT.709",
            CGColorSpace.linearGray: "Linear Gray",
            CGColorSpace.linearSRGB: "Linear sRGB",
            CGColorSpace.rommrgb: "ROMM RGB",
            CGColorSpace.sRGB: "sRGB"
        ]

        prettyNamesNyName.forEach { (key, value) in
            let colorSpace = CGColorSpace(name: key)
            XCTAssertEqual(colorSpace?.prettyName, value)
        }
    }
}
