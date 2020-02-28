//
//  TestDataOptionsViewController.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/08.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

class TestDataOptionsViewController: NSViewController {

    private struct DefaultKeys {
        static let minCount: String = "minCount"
        static let maxCount: String = "maxCount"
        static let minWidth: String = "minWidth"
        static let maxWidth: String = "maxWidth"
        static let minHeight: String = "minHeight"
        static let maxHeight: String = "maxHeight"
    }

    // MARK: - GUI

    @IBOutlet weak var minCountTextField: LinkedTextField!
    @IBOutlet weak var maxCountTextField: LinkedTextField!

    @IBOutlet weak var minWidthTextField: LinkedTextField!
    @IBOutlet weak var maxWidthTextField: LinkedTextField!

    @IBOutlet weak var minHeightTextField: LinkedTextField!
    @IBOutlet weak var maxHeightTextField: LinkedTextField!

    @IBOutlet weak var scalePopupButton: NSPopUpButton!

    @IBOutlet weak var goButton: NSButton!

    // MARK: - Retrieval of Parameter Values on Dismiss

    var minCount: Int {
        return minCountTextField.integerValue
    }

    var maxCount: Int {
        return maxCountTextField.integerValue
    }

    var minWidth: Int {
        return minWidthTextField.integerValue
    }

    var maxWidth: Int {
        return maxWidthTextField.integerValue
    }

    var minHeight: Int {
        return minHeightTextField.integerValue
    }

    var maxHeight: Int {
        return maxHeightTextField.integerValue
    }

    var scaleFactor: CGFloat {
        guard let title = scalePopupButton.selectedItem?.title else {
            return 1
        }
        return CGFloat(scaleFactorIn: title)
    }

    private var defaults: [String: Any] {
        return [
            DefaultKeys.minCount: 1,
            DefaultKeys.maxCount: 127,
            DefaultKeys.minWidth: 20,
            DefaultKeys.maxWidth: 150,
            DefaultKeys.minHeight: 30,
            DefaultKeys.maxHeight: 160
        ]
    }

    // MARK: -

    public var completionHandler: ((URL) -> Void)?

    // MARK: - NSViewController

    override func viewDidLoad() {
        UserDefaults.standard.register(defaults: defaults)

        super.viewDidLoad()
        // Do view setup here.

        minWidthTextField.constraint = .notGreater
        maxWidthTextField.constraint = .notSmaller

        minHeightTextField.constraint = .notGreater
        maxHeightTextField.constraint = .notSmaller

        minCountTextField.constraint = .notGreater
        maxCountTextField.constraint = .notSmaller

        scalePopupButton.selectItem(at: 1)

        loadDefaults()
    }

    // MARK: - Control Actions

    @IBAction func cancel(_ sender: Any) {
        view.window?.close()
    }

    @IBAction func go(_ sender: Any) {
        saveDefaults()

        promptExportDestination { [unowned self](url) in
            guard let outputURL = url else {
                return
            }
            self.view.window?.close()
            self.completionHandler?(outputURL)
        }
    }

    // MARK: -

    private func loadDefaults() {
        minCountTextField.stringValue = "\(UserDefaults.standard.integer(forKey: DefaultKeys.minCount))"
        maxCountTextField.stringValue = "\(UserDefaults.standard.integer(forKey: DefaultKeys.maxCount))"

        minWidthTextField.stringValue = "\(UserDefaults.standard.integer(forKey: DefaultKeys.minWidth))"
        maxWidthTextField.stringValue = "\(UserDefaults.standard.integer(forKey: DefaultKeys.maxWidth))"

        minHeightTextField.stringValue = "\(UserDefaults.standard.integer(forKey: DefaultKeys.minHeight))"
        maxHeightTextField.stringValue = "\(UserDefaults.standard.integer(forKey: DefaultKeys.maxHeight))"
    }

    private func saveDefaults() {

        UserDefaults.standard.set(minCount, forKey: DefaultKeys.minCount)
        UserDefaults.standard.set(maxCount, forKey: DefaultKeys.maxCount)

        UserDefaults.standard.set(minWidth, forKey: DefaultKeys.minWidth)
        UserDefaults.standard.set(maxWidth, forKey: DefaultKeys.maxWidth)

        UserDefaults.standard.set(minHeight, forKey: DefaultKeys.minHeight)
        UserDefaults.standard.set(maxHeight, forKey: DefaultKeys.maxHeight)
    }
}
