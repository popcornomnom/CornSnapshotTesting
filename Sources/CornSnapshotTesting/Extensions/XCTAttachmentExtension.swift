//
//  XCTAttachmentExtension.swift
//  CornSnapshotTesting
//
//  Created by Marharyta Lytvynenko on 02.11.21.
//  Copyright (c) 2021 Marharyta Lytvynenko. All rights reserved.
//
//  http://www.popcornomnom.com
//

import XCTest
import UIKit

extension XCTAttachment {
    convenience init(image: UIImage, name: String) {
        self.init(image: image)
        self.name = name
    }
}

extension Array where Element == XCTAttachment {
    func attachIfNeeded() {
        guard !isEmpty,
              ProcessInfo.processInfo.environment.keys
              .contains("__XCODE_BUILT_PRODUCTS_DIR_PATHS")
        else { return }

        XCTContext.runActivity(named: "Attached Failure Diff") { activity in
            forEach {
                activity.add($0)
            }
        }
    }
}
