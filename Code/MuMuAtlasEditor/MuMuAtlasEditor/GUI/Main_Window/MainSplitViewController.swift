//
//  MainSplitViewController.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

protocol MainSplitViewControllerDelegate: class {
    func splitViewController(_ splitViewController: MainSplitViewController, didCollapsePaneAtIndex index: Int)
    func splitViewController(_ splitViewController: MainSplitViewController, didExpandPaneAtIndex index: Int)
}

// MARK: -

final class MainSplitViewController: NSSplitViewController {

    weak var delegate: MainSplitViewControllerDelegate?

    override var representedObject: Any? {
        didSet {
            // Pass along to children:
            splitViewItems[0].viewController.representedObject = representedObject
            splitViewItems[1].viewController.representedObject = representedObject
        }
    }

    public var isLibraryCollapsed: Bool {
        get {
            return splitViewItems[1].animator().isCollapsed
        }
        set {
            return splitViewItems[1].animator().isCollapsed = newValue
        }
    }

    public func toggleLibrary() {
        isLibraryCollapsed = !isLibraryCollapsed
    }

    // MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    // MARK: - NSSplitViewController

    override func splitViewDidResizeSubviews(_ notification: Notification) {
        //super.splitViewDidResizeSubviews(notification) // Needed? Allowed? Check.

        if isLibraryCollapsed {
            delegate?.splitViewController(self, didCollapsePaneAtIndex: 1)
        } else {
            delegate?.splitViewController(self, didExpandPaneAtIndex: 1)
        }
    }
}
