//
//  LibraryItem.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

class LibraryCollectionViewItem: NSCollectionViewItem {

    static var identifier: NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(nibName)
    }

    static var nibName: String {
        return String(describing: self)
    }

    var source: Source? {
        didSet {
            guard isViewLoaded else {
                return
            }
            refreshView()
        }
    }

    override var isSelected: Bool {
        didSet {
            view.layer?.borderWidth = isSelected ? 5.0 : 0.0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        imageView?.imageScaling = .scaleProportionallyDown
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor

        view.layer?.borderColor = NSColor.systemBlue.cgColor
        view.layer?.borderWidth = 0.0
        view.layer?.cornerRadius = 9

        // Subscribe to changes in composition (paint self as included, excluded or failed to fit)
        NotificationCenter.default.addObserver(self, selector: #selector(didRefreshComposition(_:)), name: .documentDidRefreshComposition, object: nil)
    }

    @objc func didRefreshComposition(_ notification: Notification) {
        refreshView()
    }

    private func refreshView() {
        if let source = source {
            imageView?.image = NSImage(cgImage: source.image, size: .zero)
            textField?.stringValue = source.name

            if source.isIncluded {
                imageView?.alphaValue = 1.0
                textField?.alphaValue = 1.0

                if source.failedToFit {
                    view.layer?.backgroundColor = NSColor.red.withAlphaComponent(0.5).cgColor
                } else {
                    view.layer?.backgroundColor = NSColor(calibratedWhite: 0.8, alpha: 1).cgColor
                }
            } else {
                imageView?.alphaValue = 0.5
                textField?.alphaValue = 0.5
                view.layer?.backgroundColor = NSColor.clear.cgColor
            }
        } else {
            self.imageView?.image = nil
            self.textField?.stringValue = ""
        }
    }
}
