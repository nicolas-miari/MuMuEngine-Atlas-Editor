//
//  TestDataGeneratorTests.swift
//  AtlasEditorTests
//
//  Created by Nicolás Miari on 2019/03/20.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import MuMuAtlasEditor

class TestDataGeneratorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWriteImages() throws {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

        let folder = URL(fileURLWithPath: documents, isDirectory: true).appendingPathComponent("TestData")

        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)

        // Write single image @1x:
        try writeRandomImages(to: folder, countRange: 1 ... 1, widthRange: 1 ... 1, heightRange: 1 ... 1, scaleFactor: 1)

        // Write single image @2x:
        try writeRandomImages(to: folder, countRange: 1 ... 1, widthRange: 1 ... 1, heightRange: 1 ... 1, scaleFactor: 2)

        do {
            let contents = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [])
            XCTAssertEqual(contents.count, 2)

        } catch let error as NSError {
            print(error.localizedDescription)
        }

        try FileManager.default.removeItem(at: folder)
    }

}
