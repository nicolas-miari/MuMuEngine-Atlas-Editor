//
//  Notification+Extensions.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/14.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

extension Notification.Name {

    /**
     Broadcast by the Document object when one or more source images have been
     successfully added to or removed from its asset library.
     */
    static let documentDidModifyLibrary = Notification.Name("DocumentDidModifyLibrary")

    /**
     Broadcast by the Document object when the atlas composition has been
     refreshed.
     */
    static let documentDidRefreshComposition = Notification.Name("DocumentDidRefreshComposition")
}
