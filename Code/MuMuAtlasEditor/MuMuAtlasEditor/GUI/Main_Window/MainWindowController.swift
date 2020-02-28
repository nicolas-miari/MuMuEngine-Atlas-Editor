//
//  MainWindowController.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

final class MainWindowController: NSWindowController, MainSplitViewControllerDelegate {

    // MARK: - GUI

    private var windowBackingScaleFactor: CGFloat = 0

    /*
     - Find out why toggling of button highlight does not work when there
     is less than 2 segments. Consider using a button instead (this app will
     NEVER have a LEFT collapsible pane).
     */
    @IBOutlet weak var splitViewSegmentedControl: NSSegmentedControl!

    // MARK: - NSWindowController

    override var document: AnyObject? {
        didSet {
            // Pass document to contained view controllers so they can update
            // their contents to reflect the current document:
            self.contentViewController?.representedObject = document
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

        self.window?.delegate = self

        (contentViewController as? MainSplitViewController)?.delegate = self

        if let scale = window?.screen?.backingScaleFactor {
            self.windowBackingScaleFactor = scale
        }
    }

    // MARK: - Control Actions

    @IBAction func paneSegmentedControlChanged(_ sender: Any) {
        guard let splitViewController = self.contentViewController as? MainSplitViewController else {
            fatalError("!!!")
        }
        splitViewController.toggleLibrary()
    }

    // MARK: - MainSplitViewControllerDelegate

    func splitViewController(_ splitViewController: MainSplitViewController, didExpandPaneAtIndex index: Int) {
        if index == 1 {
            splitViewSegmentedControl.setSelected(true, forSegment: 0)
        }
    }

    func splitViewController(_ splitViewController: MainSplitViewController, didCollapsePaneAtIndex index: Int) {
        if index == 1 {
            splitViewSegmentedControl.setSelected(false, forSegment: 0)
        }
    }
}

// MARK: - NSWindowDelegate

extension MainWindowController: NSWindowDelegate {
    func windowDidChangeScreen(_ notification: Notification) {
        guard let newScreen = window?.screen else {
            return
        }
        if newScreen.backingScaleFactor != windowBackingScaleFactor {
            // Refresh preview...
        }
        self.windowBackingScaleFactor = newScreen.backingScaleFactor
    }
}
