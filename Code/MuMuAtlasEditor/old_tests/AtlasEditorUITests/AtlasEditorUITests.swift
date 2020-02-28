//
//  AtlasEditorUITests.swift
//  AtlasEditorUITests
//
//  Created by Nicolás Miari on 2019/03/20.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest

class AtlasEditorUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        let app = XCUIApplication()

        // Set custom argument to flag testing. It can be read from app code using: ProcessInfo().arguments.contains()
        app.launchArguments.append("-Testing")

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Tests

    func testChangeCanvasSizeAndUndo() {

        let app = XCUIApplication()
        let menuBarsQuery = app.menuBars

        // Create a new document:
        menuBarsQuery.menuBarItems["File"].click()
        menuBarsQuery.menuBarItems["File"].menus.menuItems["New"].click()

        // Attempt change canvas size (Cancel):
        menuBarsQuery.menuBarItems["Atlas"].click()
        menuBarsQuery.menuBarItems["Atlas"].menus.menuItems["Canvas size..."].click()
        XCUIApplication().windows["Canvas Size"].buttons["Cancel"].click()

        // Attempt change canvas size (Execute):
        menuBarsQuery.menuBarItems["Atlas"].click()
        menuBarsQuery.menuBarItems["Atlas"].menus.menuItems["Canvas size..."].click()
        XCUIApplication().windows["Canvas Size"].children(matching: .textField).element(boundBy: 0).typeText("128\t256")
        XCUIApplication().windows["Canvas Size"].buttons["OK"].click()

        // Undo it:
        menuBarsQuery.menuBarItems["Edit"].click()
        menuBarsQuery.menuBarItems["Edit"].menus.menuItems["Undo Set canvas size"].click()
    }

    func testImportAssetsUndoRedoReomoveItemAndUndoRedo() {
        let app = XCUIApplication()
        let menuBarsQuery = app.menuBars

        // Create a new document:
        menuBarsQuery.menuBarItems["File"].click()
        menuBarsQuery.menuBarItems["File"].menus.menuItems["New"].click()

        // Add sources:
        let untitledWindow = XCUIApplication().windows["Untitled"]
        untitledWindow.buttons["add"].click()

        // Undo:
        let editMenuBarItem = menuBarsQuery.menuBarItems["Edit"]
        editMenuBarItem.click()
        menuBarsQuery.menuItems["Undo Add sources"].click()

        // Redo:
        editMenuBarItem.click()
        menuBarsQuery.menuItems["Redo Add sources"].click()

        // Select item and delete
        untitledWindow.collectionViews.otherElements.children(matching: .group).matching(identifier: "LibraryCollectionViewItem").element(boundBy: 0).children(matching: .image).element.click()
        untitledWindow.buttons["remove"].click()

        // Unde delete:
        editMenuBarItem.click()
        menuBarsQuery.menuItems["Undo Remove Sources"].click()

        // Redo delete:
        editMenuBarItem.click()
        menuBarsQuery.menuItems["Redo Remove Sources"].click()
    }

    func testImportLibrarySort() {
        let app = XCUIApplication()
        let menuBarsQuery = app.menuBars

        // Create a new document:
        menuBarsQuery.menuBarItems["File"].click()
        menuBarsQuery.menuBarItems["File"].menus.menuItems["New"].click()

        // Add sources:
        let untitledWindow = XCUIApplication().windows["Untitled"]
        untitledWindow.buttons["add"].click()

        // Sort (Descending)
        let popUpButton = untitledWindow.splitGroups.children(matching: .popUpButton).element
        popUpButton.click()
        untitledWindow.menuItems["Size (Descending)"].click()

        // Sort (Ascending)
        popUpButton.click()
        untitledWindow.menuItems["Size (Ascending)"].click()

        // Sort (Name)
        popUpButton.click()
        untitledWindow.menuItems["Name"].click()
    }

    func testImportLibraryShowItemInfo() {
        let app = XCUIApplication()
        let menuBarsQuery = app.menuBars

        // Create a new document:
        menuBarsQuery.menuBarItems["File"].click()
        menuBarsQuery.menuBarItems["File"].menus.menuItems["New"].click()

        let untitledWindow = app.windows["Untitled"]
        untitledWindow.buttons["add"].click()

        let image = untitledWindow.collectionViews.otherElements.children(matching: .group).matching(identifier: "LibraryCollectionViewItem").element(boundBy: 0).children(matching: .image).element
        image.click()
        image.rightClick()
        untitledWindow.collectionViews.menuItems["Info..."].click()
        app.dialogs["Sprite Source Info"].buttons[XCUIIdentifierCloseWindow].click()
    }

    func testImportDuplicates() {
        let app = XCUIApplication()
        let menuBarsQuery = app.menuBars

        // Create a new document:
        menuBarsQuery.menuBarItems["File"].click()
        menuBarsQuery.menuBarItems["File"].menus.menuItems["New"].click()

        // Add sources:
        let untitledWindow = XCUIApplication().windows["Untitled"]
        untitledWindow.buttons["add"].click()

        // Add sources again:
        untitledWindow.buttons["add"].click()
    }

    func testImportLibrary() {
        let app = XCUIApplication()
        let menuBarsQuery = app.menuBars

        // Create a new document
        menuBarsQuery.menuBarItems["File"].click()
        menuBarsQuery.menuBarItems["File"].menus.menuItems["New"].click()

        let untitledWindow = app.windows["Untitled"]
        untitledWindow.buttons["add"].click()
        untitledWindow.splitGroups.children(matching: .popUpButton).element.click()
        untitledWindow.menuItems["Size (Ascending)"].click()

        let elementsQuery = untitledWindow.collectionViews.otherElements
        let image = elementsQuery.children(matching: .group).matching(identifier: "LibraryCollectionViewItem").element(boundBy: 0).children(matching: .image).element
        image.click()
        image.rightClick()
        untitledWindow.collectionViews.menuItems["Info..."].click()
        app.dialogs["Sprite Source Info"].buttons[XCUIIdentifierCloseWindow].click()

        let image2 = elementsQuery.children(matching: .group).matching(identifier: "LibraryCollectionViewItem").element(boundBy: 1).children(matching: .image).element
        image2.rightClick()
        untitledWindow.collectionViews.menuItems["Exclude from Atlas"].click()
        image2.rightClick()
        untitledWindow.collectionViews.menuItems["Include in Atlas"].click()
        elementsQuery.children(matching: .group).matching(identifier: "LibraryCollectionViewItem").element(boundBy: 2).children(matching: .image).element.rightClick()
        untitledWindow.collectionViews.menuItems["Remove from Library"].click()
        elementsQuery.children(matching: .group).matching(identifier: "LibraryCollectionViewItem").element(boundBy: 3).children(matching: .image).element.click()
        untitledWindow.buttons["remove"].click()

    }

    func testLibraryEmptyClick() {
        let app = XCUIApplication()
        let menuBarsQuery = app.menuBars

        menuBarsQuery.menuBarItems["File"].click()
        menuBarsQuery.menuItems["New"].click()

        let collectionView = app.windows["Untitled"].splitGroups.children(matching: .scrollView).element(boundBy: 1).children(matching: .collectionView).element
        collectionView.rightClick()
    }

    func testExport() {
        let app = XCUIApplication()
        let menuBarsQuery = app.menuBars

        // Create a new document
        menuBarsQuery.menuBarItems["File"].click()
        menuBarsQuery.menuBarItems["File"].menus.menuItems["New"].click()

        let untitledWindow = app.windows["Untitled"]
        untitledWindow.buttons["add"].click()

        let button = untitledWindow.toolbars.children(matching: .button).element
        button.click()

        let exportOptionsWindow = app.windows["Export Options"]
        exportOptionsWindow.checkBoxes["@3x"].click()
        exportOptionsWindow.checkBoxes["@2x"].click()
        exportOptionsWindow.buttons["Export"].click()
        button.click()
        exportOptionsWindow.buttons["Cancel"].click()
    }

    func testSaveDocument() {
        let menuBarsQuery = XCUIApplication().menuBars
        let fileMenuBarItem = menuBarsQuery.menuBarItems["File"]

        fileMenuBarItem.click()
        menuBarsQuery.menuItems["New"].click()

        fileMenuBarItem.click()
        menuBarsQuery.menuItems["Save…"].click()
    }

    func testValidZoomFactor() {
        let app = XCUIApplication()
        let menuBarsQuery = app.menuBars

        menuBarsQuery.menuBarItems["File"].click()
        menuBarsQuery.menuItems["New"].click()

        let untitledWindow = app.windows["Untitled"]
        untitledWindow.comboBoxes.children(matching: .button).element.click()
        untitledWindow.scrollViews.otherElements.children(matching: .textField).element(boundBy: 6).click()
    }

    func testBogusZoomFactor() {
        let app = XCUIApplication()
        let menuBarsQuery = app.menuBars

        menuBarsQuery.menuBarItems["File"].click()
        menuBarsQuery.menuItems["New"].click()

        let comboBox = app.windows["Untitled"].splitGroups.children(matching: .comboBox).element
        comboBox.doubleClick()
        comboBox.typeKey(.delete, modifierFlags: [])
        comboBox.typeText("er\r")
    }

    func testUndo() {

    }

    func testSplitView() {

        let app = XCUIApplication()
        let menuBarsQuery = app.menuBars

        menuBarsQuery.menuBarItems["File"].click()
        menuBarsQuery.menuItems["New"].click()

        let untitledWindow = app.windows["Untitled"]
        let checkBox = untitledWindow.toolbars.children(matching: .group).element.children(matching: .group).element.children(matching: .checkBox).element
        checkBox.click()
        checkBox.click()

        let splitter = untitledWindow.splitGroups.children(matching: .splitter).element
        splitter.click()
        splitter.click()
        splitter.click()
    }
}
