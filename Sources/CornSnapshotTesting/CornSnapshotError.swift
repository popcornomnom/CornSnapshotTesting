//
//  CornSnapshotError.swift
//  CornSnapshotTesting
//
//  Created by Marharyta Lytvynenko on 02.11.21.
//  Copyright (c) 2021 Marharyta Lytvynenko. All rights reserved.
//
//  http://www.popcornomnom.com
//

import Foundation

enum CornSnapshotError: Error {
    case noReferenceFeatureprints
    case noActualFeatureprints
    case cgImageDoesNotExist
}
