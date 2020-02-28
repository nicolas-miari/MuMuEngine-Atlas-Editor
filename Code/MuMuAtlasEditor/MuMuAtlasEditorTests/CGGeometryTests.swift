//
//  CGGeometryTests.swift
//  AtlasEditorTests
//
//  Created by Nicolás Miari on 2019/03/19.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import MuMuAtlasEditor

/**
 Tests the methods and properties of the app's extensions to CoreGraphics's
 `CGPoint`, `CGSize`, and `CGRect` structures.
 */
class CGGeometryTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testScaling() {
        let x: CGFloat = 10
        let y: CGFloat = 13
        let width: CGFloat = 200
        let height: CGFloat = 300

        let scaleFactor: CGFloat = -3.5

        let rect = CGRect(x: x, y: y, width: width, height: height)
        let scaledRect = rect.scaledBy(scaleFactor)

        XCTAssertEqual(scaledRect.origin.x, rect.origin.x * scaleFactor)
        XCTAssertEqual(scaledRect.origin.y, rect.origin.y * scaleFactor)
        XCTAssertEqual(scaledRect.width, rect.width * abs(scaleFactor))
        XCTAssertEqual(scaledRect.height, rect.height * abs(scaleFactor))
    }

    func testFits() {
        let firstRect = CGRect(origin: .zero, size: CGSize(width: 200, height: 300))
        let secondRect = CGRect(origin: .zero, size: CGSize(width: 199, height: 299))

        // Check the smaller one fots inside the larger one:
        XCTAssertTrue(secondRect.fits(in: firstRect))

        // Check the larger one does NOT fir inside the smaller one:
        XCTAssertFalse(firstRect.fits(in: secondRect))

        // Check that both fit within themselves:
        XCTAssertTrue(firstRect.fits(in: firstRect))
        XCTAssertTrue(secondRect.fits(in: secondRect))
    }

    func testArea() {
        let width: CGFloat = 200
        let height: CGFloat = 300
        let rect1 = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        let rect2 = rect1.offsetBy(dx: 10, dy: 20)

        // Check that area is the expected value, and independent of origin:
        XCTAssertEqual(rect1.area, width * height)
        XCTAssertEqual(rect1.area, rect2.area)
    }

    func testInset() {
        let x: CGFloat = 10
        let y: CGFloat = 14
        let width: CGFloat = 200
        let height: CGFloat = 300
        let margin: CGFloat = 2
        let rect1 = CGRect(x: x, y: y, width: width, height: height)

        let insetRect = rect1.insetBy(margin)

        XCTAssertEqual(insetRect.origin.x, x + margin)
        XCTAssertEqual(insetRect.origin.y, y + margin)
        XCTAssertEqual(insetRect.size.width, width - 2*margin)
        XCTAssertEqual(insetRect.size.height, height - 2*margin)
    }
}
