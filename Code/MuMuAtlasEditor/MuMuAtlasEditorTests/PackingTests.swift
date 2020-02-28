//
 //  PackingTests.swift
//  AtlasEditorTests
//
//  Created by Nicolás Miari on 2019/03/18.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import MuMuAtlasEditor

/**
 Tests the `pack(sources: in:)` (sprite packing algorithm) under various inputs.
 */
class PackingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /**
     Checks that two sprites (of different sizes) that neatly fill the canvas
     sized-by-side are actually packed at the expected locations.
     */
    func testTightTwoPacking() {
        let canvasSize = CGSize(width: 256, height: 256)
        let sources = [
            Source(name: "01", size: CGSize(width: 192, height: 256)), // 3/4 the width, full height
            Source(name: "02", size: CGSize(width: 256, height: 64))  // remaining width, full height (needs rotating)
        ]

        let sprites = pack(sources: sources, in: canvasSize)

        // Assert that all sources were packed:
        XCTAssertEqual(sources.count, sprites.count)

        // Assert that all sources where packed in the expected place:
        XCTAssertEqual(sprites[0].targetRect, CGRect(origin: .zero, size: CGSize(width: 192, height: 256)))
        XCTAssertEqual(sprites[1].targetRect, CGRect(origin: CGPoint(x: 192, y: 0), size: CGSize(width: 64, height: 256)))
    }

    /**
     Checks that four sprites of varying sizes that neatly fill the canvas in a
     2 by 2 configuration are actually packed at the expected locations.
     */
    func testTightFourPacking() {
        let canvasSize = CGSize(width: 256, height: 256)

        let sources = [
            Source(name: "01", size: CGSize(width: 192, height: 192)), // large square
            Source(name: "02", size: CGSize(width: 64, height: 64)),   // small square
            Source(name: "03", size: CGSize(width: 192, height: 64)),  // two rectangles that fill the remaining space (one rotated)
            Source(name: "04", size: CGSize(width: 192, height: 64))  //
        ]
        let sprites = pack(sources: sources, in: canvasSize)

        // Assert that all sources were packed:
        XCTAssertEqual(sources.count, sprites.count)

        // Assert that all sources where packed in the expected place:
        XCTAssertEqual(sprites[0].targetRect, CGRect(origin: .zero, size: CGSize(width: 192, height: 192)))
        XCTAssertEqual(sprites[1].targetRect, CGRect(origin: CGPoint(x: 0, y: 192), size: CGSize(width: 192, height: 64)))
        XCTAssertEqual(sprites[2].targetRect, CGRect(origin: CGPoint(x: 192, y: 0), size: CGSize(width: 64, height: 192)))
        XCTAssertEqual(sprites[3].targetRect, CGRect(origin: CGPoint(x: 192, y: 192), size: CGSize(width: 64, height: 64)))
    }

    /**
     Checks that a single sprite small enough to fit in the canvas is actually
     packed in a rectangle extending from the canvas's origin.
     */
    func testSingleSmallSprite() {
        let canvasSize = CGSize(width: 256, height: 256)

        let source = Source(name: "Fits", size: CGSize(width: canvasSize.width - 1, height: canvasSize.height - 1))
        let sprites = pack(sources: [source], in: canvasSize)

        XCTAssertEqual(sprites.count, 1)
        XCTAssertEqual(sprites[0].targetRect, CGRect(origin: .zero, size: CGSize(width: canvasSize.width - 1, height: canvasSize.height - 1)))
    }

    /**
     Checks that a single sprite too large to fit in the canvas in one
     dimension is rejected.
     */
    func testFailureToFitSingleSpriteWidth() {
        let canvasSize = CGSize(width: 256, height: 256)

        let source = Source(name: "TooBig", size: CGSize(width: canvasSize.width + 1, height: 1))
        let sprites = pack(sources: [source], in: canvasSize)

        XCTAssertEqual(sprites.count, 0)
    }

    /**
     Checks that a single sprite too large to fit in the canvas in both
     dimension is rejected.
     */
    func testFailureToFitSingleSpriteBothDimensions() {
        let canvasSize = CGSize(width: 256, height: 256)

        let source = Source(name: "TooBig", size: CGSize(width: canvasSize.width + 1, height: canvasSize.height + 1))
        let sprites = pack(sources: [source], in: canvasSize)

        XCTAssertEqual(sprites.count, 0)
    }

    /**
     For code coverage.
     */
    func testRunOutOfEmptySpace() {
        let canvasSize = CGSize(width: 256, height: 256)

        let source1 = Source(name: "First Half", size: CGSize(width: canvasSize.width - 10, height: canvasSize.height))
        let source2 = Source(name: "Second Half", size: CGSize(width: 10, height: canvasSize.height))
        let source3 = Source(name: "Won't Fit", size: CGSize(width: 1, height: 1))
        let sources = [source1, source2, source3]

        let sprites = pack(sources: sources, in: canvasSize)

        XCTAssertLessThan(sprites.count, sources.count)
    }

    /**
     Checks that sprites with zero width or height are rejected by the packing
     function (even if the other domension fits in the canvas).
     */
    func testNullSprites() {
        let canvasSize = CGSize(width: 256, height: 256)

        let sources = [
            Source(name: "Too Thin", size: CGSize(width: 0, height: 128)),
            Source(name: "Too Short", size: CGSize(width: 147, height: 0))
        ]
        let sprites = pack(sources: sources, in: canvasSize)

        XCTAssertEqual(sprites.count, 0)
    }

    func testSplit() {
        let whole = CGRect(x: 0, y: 0, width: 256, height: 256)

        let remnants = split(sourceRect: whole, byRemovingFromTopLeft: CGSize(width: 128, height: 128))

        XCTAssertEqual(remnants.count, 2)
    }
}
