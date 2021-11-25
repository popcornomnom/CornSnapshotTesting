//
//  XCTestCaseExtension.swift
//  CornSnapshotTesting
//
//  Created by Marharyta Lytvynenko on 02.11.21.
//  Copyright (c) 2021 Marharyta Lytvynenko. All rights reserved.
//
//  http://www.popcornomnom.com
//

import Foundation
import XCTest

public extension XCTestCase {
         
    /**
     Compares the snapshot of the current window with the previously saved reference image.
     
     This method takes a window snapshot of the current device.
     
     The test result depends on the similarity of images, taking into account the tolerance factor.
     - SeeAlso: ``CornSnapshotConfiguration/tolerance``.
     
     The reference image won't be changed in case of a failed test result.
     
     - Precondition: You have to call this method after an app has already launched.
     
     - Note: An example of using:
     ```
     assertSnapshot("manual_search_screen", "Search")
     ```
     In this particular example, the snapshot will be placed by the path:
     ```
     ${path}/Snapshots/Search/manual_search_screen-iPhone8.png
     ```
     
     - Parameters:
        - delay: The time interval in seconds after which the snapshot will be taken. For example, the time needed for an animation to be completed.
        - name: The snapshot file name. By default, this value is equal to the function name.
        - path: The path to the folder where the snapshot is placed. By default, this value is equal to the caller's file path.
        - folderComponents: Additional path components for subfolders.
        - interfaceStyle: The current interface appearance of the app during the test. It's used to add the current app theme to the snapshot file name.
        - file: File of the caller.
        - function: The caller.
     */
    final func assertSnapshot(delay: TimeInterval = 0,
                              name: String? = nil,
                              path: String? = nil,
                              folderComponents: String...,
                              interfaceStyle: UIUserInterfaceStyle? = nil,
                              file: String = #file,
                              function: String = #function) {
        // 1. Assign function name as the default name if needed
        var name = name ?? function.replacingOccurrences(of: "()", with: "")

        // 2. Append current theme if needed
        if let interfaceStyle = interfaceStyle {
            name.append(interfaceStyle == .light ? "-light" : "-dark")
        }
        
        // 3. Assign caller's file path as the default path if needed
        let path = path ?? file.components(separatedBy: "/").dropLast().joined(separator: "/")
        
        // 4. Check the weather provided path is valid
        var isPathValid = ObjCBool(false)
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isPathValid) else {
            XCTFail("Invalid directory path: \(path)")
            return
        }
        
        // 5. Assert snapshot
        CornSnapshotService.shared.assertSnapshot(
            delay: delay,
            name: name, path: path, folderComponents: folderComponents,
            file: file, function: function
        )
    }
}
