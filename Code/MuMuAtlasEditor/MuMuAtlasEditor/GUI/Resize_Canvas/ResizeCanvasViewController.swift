//
//  ResizeCanvasViewController.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/12.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 Allows the user to change the current document's  canvas size.
 */
class ResizeCanvasViewController: NSViewController {

    // MARK: - GUI

    @IBOutlet weak var widthTextField: NSTextField!
    @IBOutlet weak var heightTextField: NSTextField!

    /**
     Set to document's current canvas size before presenting, retrieve newly
     requested canvas size on successful dismissal (OK button).
     */
    var size: CGSize? {
        didSet {
            updateTextFields()
        }
    }

    /**
     Executed on dismissal. Argument is `true` if user accepted, `false` if
     cancelled.
     */
    var closeHandler: ((Bool) -> Void)?

    // MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        updateTextFields()
    }

    // MARK: - Control Actions

    @IBAction func cancel(_ sender: Any) {
        closeHandler?(false)
    }

    @IBAction func ok(_ sender: Any) {
        self.size = CGSize(width: CGFloat(widthTextField.floatValue), height: CGFloat(heightTextField.floatValue))
        closeHandler?(true)
    }

    // MARK: -

    private func updateTextFields() {
        widthTextField.stringValue = "\(Int(size?.width ?? 0))"
        heightTextField.stringValue = "\(Int(size?.height ?? 0))"
    }
}
