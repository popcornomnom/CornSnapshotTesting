//
//  CornSnapshotConfiguration.swift
//  CornSnapshotTesting
//
//  Created by Marharyta Lytvynenko on 02.11.21.
//  Copyright (c) 2021 Marharyta Lytvynenko. All rights reserved.
//
//  http://www.popcornomnom.com
//

import Foundation
import CoreImage

public final class CornSnapshotConfiguration {

    /// Singletone instance of ``CornSnapshotConfiguration``.
    public static let current = CornSnapshotConfiguration()
    
    /**
     An acceptable snapshot difference factor.
     
     If you want snapshots to match pixel-to-pixel, you can use the value `0`. By default, the value is `0`.

     If you use the `CI` tool to run tests, you may have a difference in the image quality between devices.
     Therefore, I would recommend using a higher `tolerance` value.

     An example of using:
     ```swift
     class ExampleTests: XCTestCase {
         override func setUp() {
             super.setUp()
             CornSnapshotConfiguration.current.tolerance = 0
         }
     }
     ```
     */
    public var tolerance: Float = 0
    
    /**
     The color used by the difference image to highlight the areas of difference between the two snapshots.
     By default `highlighterColor` is `red`.
     */
    public var highlighterColor: CIColor = .red
}
