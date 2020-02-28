//
//  SourceTests.swift
//  AtlasEditorTests
//
//  Created by Nicolás Miari on 2019/03/19.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import MuMuAtlasEditor

/**
 Tests the interface of the model class `Source`.
 */
class SourceTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSuccessfulInitialization() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "test_01", ofType: "png") else {
            fatalError("")
        }

        let source = Source(contentsOfFile: path)

        XCTAssertNotNil(source)
        XCTAssertNotNil(source?.image)
    }

    func testSuccessfulInitializationHiResImage() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "test_02@2x", ofType: "png") else {
            fatalError("")
        }

        let source = Source(contentsOfFile: path)

        XCTAssertNotNil(source)
        XCTAssertNotNil(source?.image)
    }

    func testFailedInitializationNotAnImage() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "not_an_image", ofType: "txt") else {
            fatalError("")
        }

        let source = Source(contentsOfFile: path)
        XCTAssertNil(source)
    }

    func testFailedInitializationFileNotFound() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "test_01", ofType: "png") else {
            fatalError("")
        }
        let source = Source(contentsOfFile: path + "aaa")
        XCTAssertNil(source)
    }

    func testInitMalformedScaleSpecifier() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "malformed@x", ofType: "png") else {
            fatalError("")
        }
        let source = Source(contentsOfFile: path)
        XCTAssertEqual(source?.scaleFactor, CGFloat(1))
    }

    func testInitFromImage() throws {
        let bundle = Bundle(for: type(of: self))

        /*
        guard let url = bundle.url(forResource: "test_01", withExtension: "png") else {
            fatalError("")
        }
        let data = try Data(contentsOf: url)

        guard let image = NSBitmapImageRep(data: data)?.cgImage else {
            fatalError("")
        }*/

        //let resourceName = "test_01"
        let resourceName = "TestImage_01"

        guard let image = bundle.image(forResource: resourceName)?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError("Resource is missing!")
        }

        let source1 = Source(name: "Name 1", image: image, scaleFactor: 1, isOpaque: true)
        XCTAssertEqual(source1.image, image)

        let source2 = Source(name: "Name 2", image: image, scaleFactor: 1, isOpaque: true)
        XCTAssertEqual(source2.image, image)
    }

    func testEquality() {
        let source1 = Source(name: "Same Name", size: CGSize(width: 200, height: 300))
        let source2 = Source(name: "Same Name", size: CGSize(width: 400, height: 500))

        XCTAssertEqual(source1, source2)
    }

    func testInspectableAttributes() {
        let width: CGFloat = 100
        let height: CGFloat = 150
        let scale: CGFloat = 2.0

        let source = Source(name: "Name", size: CGSize(width: width, height: height), scaleFactor: scale)

        XCTAssertEqual(source.pointWidth, Int(width))
        XCTAssertEqual(source.pointHeight, Int(height))
        XCTAssertEqual(source.pixelWidth, Int(width * scale))
        XCTAssertEqual(source.pixelHeight, Int(height * scale))
        XCTAssertEqual(source.scaleFactor, scale)
    }
}
