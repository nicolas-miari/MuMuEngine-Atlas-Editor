//
//  RendererTests.swift
//  AtlasEditorTests
//
//  Created by Nicolás Miari on 2019/03/19.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import MuMuAtlasEditor

class RendererTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRenderPreview() throws {

        let sprite1 = try testSprite(rotated: false)
        let sprite2 = try testSprite(rotated: true)
        let sprites = [sprite1, sprite2]
        let canvasSize = CGSize(width: 32, height: 32)

        let preview = try renderPreview(sprites: sprites, canvasSize: canvasSize, scaleFactor: 1, drawOutlines: false)
        let previewWithOutlines = try renderPreview(sprites: sprites, canvasSize: canvasSize, scaleFactor: 1, drawOutlines: true)

        XCTAssertNotNil(preview)
        XCTAssertNotNil(previewWithOutlines)
    }

    func testRenderTexture() throws {
        let sprite = try testSprite(rotated: false)
        let canvasSize = CGSize(width: 32, height: 32)

        _ = try renderTexture(sprites: [sprite], canvasSize: canvasSize, scaleFactor: 1)
    }

    // MARK: - Support

    func testSource() throws -> Source {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "test_01", ofType: "png") else {
            throw NSError(localizedDescription: "!!!")
        }
        guard let source = Source(contentsOfFile: path) else {
            throw NSError(localizedDescription: "!!!")
        }
        return source
    }

    private func testSprite(rotated: Bool) throws -> Sprite {
        let source = try testSource()
        return Sprite(source: source, position: .zero, rotated: rotated)
    }
}
