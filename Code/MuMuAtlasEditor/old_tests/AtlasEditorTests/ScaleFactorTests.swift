//
//  ScaleFactorTests.swift
//  AtlasEditorTests
//
//  Created by Nicolás Miari on 2019/03/18.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import MuMuAtlasEditor

/**
 Tests the behaviour of the global `scaleFactor(in:)` function under various
 inputs.
 */
class ScaleFactorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNoDescriptors() {
        let fileName = "filename.png"
        let factor = CGFloat(scaleFactorIn: fileName)
        XCTAssertEqual(factor, 1.0)
    }

    func testOneDescriptor() {
        let fileName = "filename@2x.png"
        let factor = CGFloat(scaleFactorIn: fileName)
        XCTAssertEqual(factor, 2.0)
    }

    func testRedundantDescriptor() {
        let fileName = "filename@1x.png"
        let factor = CGFloat(scaleFactorIn: fileName)
        XCTAssertEqual(factor, 1.0)
    }

    func testMultipleDescriptors() {
        let fileName = "filename@2x@3x@4x.png"
        let factor = CGFloat(scaleFactorIn: fileName)
        XCTAssertEqual(factor, 4.0)
    }

    func testDecimalPoint() {
        let fileName = "filename@2.5x.png"
        let factor = CGFloat(scaleFactorIn: fileName)
        XCTAssertEqual(factor, 2.5)
    }

    func testFileNameContainingDigits() {
        let fileName = "image074@3x.png"
        let factor = CGFloat(scaleFactorIn: fileName)
        XCTAssertEqual(factor, 3)
    }

    func testNoNumericalValue() {
        let fileName = "image074@x.png"
        let factor = CGFloat(scaleFactorIn: fileName)
        XCTAssertEqual(factor, 1.0)
    }
}
