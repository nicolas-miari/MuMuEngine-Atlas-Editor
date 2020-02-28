//
//  NSErrorTests.swift
//  AtlasEditorTests
//
//  Created by Nicolás Miari on 2019/03/19.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest

@testable import MuMuAtlasEditor

/**
 Tests the methods and properties of the app's extensions to Foundation's
 `NSError` class.
 */
class NSErrorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConvenineceInitializer() {

        let localizedDecription = "Test Localized Description"

        let error = NSError(localizedDescription: localizedDecription)

        // Check that the appropriate entry in userInfo was set:
        XCTAssertEqual(error.userInfo[NSLocalizedDescriptionKey] as? String, localizedDecription)

        // Check that the shortcut property also matches:
        XCTAssertEqual(error.localizedDescription, localizedDecription)
    }
}
