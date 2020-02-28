//
//  AppDelegate.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var testOptionsWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        /*
         Consider implementing 'Welcome' screen with recents list from
         NSDocumentController.shared.recentDocumentURLs
         */
        return false
    }

    @IBAction func generateTestData(_ sender: NSMenu) {
        // These forced casts are guaranteed to succeed at compile time by
        // virtue of the storyboard structure.
        let windowController = NSStoryboard(name: "TestDataOptions", bundle: nil).instantiateInitialController() as! NSWindowController
        let viewController = windowController.contentViewController as! TestDataOptionsViewController

        self.testOptionsWindowController = windowController
        windowController.showWindow(self)
        windowController.window?.center()

        viewController.completionHandler = { (outputDirectory) in
            let wRange = viewController.minWidth ... viewController.maxWidth
            let hRange = viewController.minHeight ... viewController.maxHeight
            let cRange = viewController.minCount ... viewController.maxCount
            let scale = viewController.scaleFactor

            do {
                try writeRandomImages(to: outputDirectory, countRange: cRange, widthRange: wRange, heightRange: hRange, scaleFactor: scale)
            } catch {
                NSAlert(error: error).runModal()
            }
        }
    }
}

extension AppDelegate: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
}
