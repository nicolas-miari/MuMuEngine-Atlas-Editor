//
//  AppConfiguration.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

struct AppConfiguration {

    /**
     The default canvas size used in new documents, in **points**.
     */
    static var defaultCanvasSize: CGSize {
        //set {
        //    Implement (Preferences Pane)
        //}
        //get {
            return CGSize(width: 1024, height: 1024)
        //}
    }

    static var defaultExportScaleFactors: [CGFloat] {
        return [1.0, 2.0]
    }
}
