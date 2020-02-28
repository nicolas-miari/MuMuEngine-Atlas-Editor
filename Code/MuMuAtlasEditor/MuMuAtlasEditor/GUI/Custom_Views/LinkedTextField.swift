//
//  LinkedTextField.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/27.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 Custom text field that adjusts its string value when editing ends so that it
 remains constrained to the value of another, associated text field.
 */
class LinkedTextField: NSTextField {

    enum Constraint {
        case none

        /// Should not be greater than the value of the associated text field
        case notGreater

        /// Should not be smaller than the value of the associated text field
        case notSmaller
    }

    var constraint: Constraint = .none

    @IBOutlet weak var associatedTextField: NSTextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        applyConstraint()
    }

    override func textShouldEndEditing(_ textObject: NSText) -> Bool {
        applyConstraint()
        return true
    }

    func applyConstraint() {
        switch constraint {
        case .none:
            break // (covered by the call in awakeFromNib())

        case .notGreater:
            if integerValue > associatedTextField.integerValue {
                self.stringValue = "\(associatedTextField.integerValue)"
            }
        case .notSmaller:
            if integerValue < associatedTextField.integerValue {
                self.stringValue = "\(associatedTextField.integerValue)"
            }
        }
    }
}
