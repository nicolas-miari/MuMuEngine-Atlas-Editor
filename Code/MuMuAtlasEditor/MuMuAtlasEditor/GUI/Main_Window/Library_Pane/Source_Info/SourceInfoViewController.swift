//
//  SourceInfoViewController.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/11.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 Manages the content view displayed in the Info window accessed from the context
 menu for each library item.
 */
class SourceInfoViewController: NSViewController {

    // MARK: - GUI

    @IBOutlet weak var thumbnailImageView: NSImageView!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var pointSizeLabel: NSTextField!
    @IBOutlet weak var scaleFactorLabel: NSTextField!
    @IBOutlet weak var pixelSizeLabel: NSTextField!
    @IBOutlet weak var colorSpaceLabel: NSTextField!
    @IBOutlet weak var anchorPointLabel: NSTextField!

    // MARK: -

    private var editAnchorWindowController: NSWindowController!

    // MARK: - ViewModel

    var source: Source? {
        didSet {
            guard let source = source else {
                return
            }
            thumbnailImageView.image = NSImage(cgImage: source.image, size: .zero)
            nameTextField.stringValue = source.name
            pointSizeLabel.stringValue = "\(source.pointWidth) x \(source.pointHeight)"
            scaleFactorLabel.stringValue = "@\(Int(source.scaleFactor))x"
            pixelSizeLabel.stringValue = "\(source.pixelWidth) x \(source.pixelHeight)"
            colorSpaceLabel.stringValue = source.image.colorSpace?.prettyName ?? "(Unknown Color Space)"

            let x = Int(source.anchorPoint.x)
            let y = Int(source.anchorPoint.y)
            anchorPointLabel.stringValue = "(\(x), \(y))"
        }
    }

    @IBAction func changeAnchorPoint(_ sender: Any) {
        if editAnchorWindowController == nil {
            guard let windowController = NSStoryboard(name: "AnchorPointEditor", bundle: nil).instantiateInitialController() as? NSWindowController else {
                fatalError("Storyboard Inconsistency")
            }
            self.editAnchorWindowController = windowController

            guard let viewController = windowController.contentViewController as? AnchorPointEditorViewController else {
                fatalError("Storyboard Inconsistency")
            }
            viewController.source = source
        }
        editAnchorWindowController.window?.makeKeyAndOrderFront(self)
    }
}
