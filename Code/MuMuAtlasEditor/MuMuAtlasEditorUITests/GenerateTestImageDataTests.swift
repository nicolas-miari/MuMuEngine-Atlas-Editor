//
//  GenerateTestImageDataTests.swift
//  AtlasEditorUITests
//
//  Created by Nicolás Miari on 2019/03/25.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest

class GenerateTestImageDataTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        let app = XCUIApplication()

        // Set custom argument to flag testing. It can be read from app code using: ProcessInfo().arguments.contains()
        app.launchArguments.append("-Testing")

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test01TestDataOptionsPanelCancel() {
        let app = XCUIApplication()

        let menuBarsQuery = app.menuBars
        menuBarsQuery.menuBarItems["Develop"].click()
        menuBarsQuery.menuItems["Generate Test Sprites..."].click()
        app.windows["Test Data Settings"].buttons["Cancel"].click()
    }

    func test02TestDataOptionsPanelGoWithDefaults() {
        let app = XCUIApplication()
        let menuBarsQuery = app.menuBars
        menuBarsQuery.menuBarItems["Develop"].click()
        menuBarsQuery.menuItems["Generate Test Sprites..."].click()

        let testDataSettingsWindow = app.windows["Test Data Settings"]
        testDataSettingsWindow.children(matching: .textField).element(boundBy: 0).typeText("12\t")
        testDataSettingsWindow.children(matching: .textField).element(boundBy: 1).typeText("9\t")
        testDataSettingsWindow.children(matching: .textField).element(boundBy: 2).typeText("\t")
        testDataSettingsWindow.children(matching: .textField).element(boundBy: 3).typeText("\t")
        testDataSettingsWindow.children(matching: .textField).element(boundBy: 4).typeText("\t")
        testDataSettingsWindow.buttons["Go..."].click()
    }
}
