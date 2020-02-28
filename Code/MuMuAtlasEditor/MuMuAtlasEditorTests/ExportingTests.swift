//
//  ExportingTests.swift
//  AtlasEditorTests
//
//  Created by Nicolás Miari on 2019/03/27.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import MuMuAtlasEditor

class ExportingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExporting() throws {

        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "test_01", ofType: "png") else {
            fatalError()
        }
        guard let source = Source(contentsOfFile: path) else {
            fatalError()
        }

        let canvasSize = CGSize(width: 128, height: 128)

        let sprites = pack(sources: [source], in: canvasSize)

        let scaleFactors: Set<CGFloat> = [1, 2, 3]
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())

        let name = UUID().uuidString

        try exportTextureSet(name: name, for: sprites, inCanvasSize: canvasSize, atScaleFactors: scaleFactors, to: tempURL)

        let folderName = name + ".textureset"
        let folderPath = tempURL.appendingPathComponent(folderName).path
        var isDirectory: ObjCBool = false
        let folderExists = FileManager.default.fileExists(atPath: folderPath, isDirectory: &isDirectory)
        XCTAssertTrue(folderExists)
        XCTAssertTrue(isDirectory.boolValue)

        try exportMetadata(name: name, for: sprites, inCanvasSize: canvasSize, to: tempURL)

        let fileName = name + ".json"
        let filePath = tempURL.appendingPathComponent(fileName).path
        let fileExists = FileManager.default.fileExists(atPath: filePath, isDirectory: nil)
        XCTAssertTrue(fileExists)
    }
}
