//
//  SpriteTests.swift
//  AtlasEditorTests
//
//  Created by Nicolás Miari on 2019/03/19.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import MuMuAtlasEditor

class SpriteTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSprite() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "test_01", ofType: "png") else {
            fatalError("")
        }
        guard let source = Source(contentsOfFile: path) else {
            fatalError("")
        }
        let sprite1 = Sprite(source: source, position: .zero, rotated: false)
        let sprite2 = Sprite(source: source, position: .zero, rotated: true)

        XCTAssertEqual(sprite1.sourceImage, source.image)
        XCTAssertEqual(sprite2.sourceImage, source.image)

        XCTAssertEqual(sprite1.nativeSize, source.pointSize)
        XCTAssertEqual(sprite2.nativeSize, source.pointSize)
    }

}
