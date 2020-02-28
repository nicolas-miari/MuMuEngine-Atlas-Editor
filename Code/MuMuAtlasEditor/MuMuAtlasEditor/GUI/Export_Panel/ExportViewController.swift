//
//  ExportViewController.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/15.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 Manages the content view of the panel that is displayed when theuser chooses
 to export the atlas for the current document.
 Allows for configuring the export options.
 */
class ExportViewController: NSViewController {

    // MARK: - GUI

    @IBOutlet private(set) var checkbox1: NSButton!
    @IBOutlet private(set) var checkbox2: NSButton!
    @IBOutlet private(set) var checkbox3: NSButton!

    @IBOutlet private(set) var warningIcon1: NSImageView!
    @IBOutlet private(set) var warningIcon2: NSImageView!
    @IBOutlet private(set) var warningIcon3: NSImageView!

    @IBOutlet private(set) var diagnosticLabel1: NSTextField!
    @IBOutlet private(set) var diagnosticLabel2: NSTextField!
    @IBOutlet private(set) var diagnosticLabel3: NSTextField!

    @IBOutlet private(set) var okButton: NSButton!

    // MARK: - Configuration

    /**
     The sources to export. Used to determine the scale factors that can be
     exported without oversampling.
     */
    var sources: [Source] = [] {
        didSet {
            updateDiagnosticLabels()
        }
    }

    /**
     The scale factors that are to be exported.
     */
    var selectedScaleFactors: Set<CGFloat> {
        set {
            checkboxes.enumerated().forEach { (index, checkbox) in
                let factor = CGFloat(index + 1)
                checkbox.state = newValue.contains(factor) ? .on : .off
            }
        }
        get {
            return Set(checkboxes.enumerated().compactMap({ (index, checkbox) -> CGFloat? in
                guard checkbox.state == .on else { return nil }
                return CGFloat(index + 1)
            }))
        }
    }

    /**
     A closure executed when the user closes the window. The sole parameter gets
     the value `true` on the user selecting "OK", `false` on "Cancel".
     */
    var dismissHandler: ((Bool) -> Void)?

    // MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    // MARK: - Control Actions

    @IBAction func checkboxChanged(_ sender: NSButton) {
        validateOkButton()
    }

    @IBAction func cancel(_ sender: NSButton) {
        dismissHandler?(false)
    }

    @IBAction func ok(_ sender: NSButton) {
        dismissHandler?(true)
    }

    // MARK: -

    private var checkboxes: [NSButton] {
        return [checkbox1, checkbox2, checkbox3]
    }

    private var warningIcons: [NSImageView] {
        return [warningIcon1, warningIcon2, warningIcon3]
    }

    private var diagnosticLabels: [NSTextField] {
        return [diagnosticLabel1, diagnosticLabel2, diagnosticLabel3]
    }

    private func updateDiagnosticLabels() {
        for (index, checkbox) in checkboxes.enumerated() {
            let scaleFactor = CGFloat(index + 1)
            let sourcesSupportingScaleFactor = sources.filter { $0.scaleFactor >= scaleFactor }

            if sourcesSupportingScaleFactor.count < sources.count {
                diagnosticLabels[index].stringValue = "Some sources are not available at this resolution: quality might be compromised by upsampling. "
                diagnosticLabels[index].textColor = NSColor.systemRed
            } else {
                diagnosticLabels[index].stringValue = "All sources support this resolution or higher."
                diagnosticLabels[index].textColor = NSColor.systemGreen
                warningIcons[index].removeFromSuperview()
            }
            checkbox.state = AppConfiguration.defaultExportScaleFactors.contains(scaleFactor) ? .on : .off
        }
    }

    private func validateOkButton() {
        let first = checkboxes.first { $0.state == .on }
        if first == nil {
            okButton.isEnabled = false
        } else {
            okButton.isEnabled = true
        }
    }
}
