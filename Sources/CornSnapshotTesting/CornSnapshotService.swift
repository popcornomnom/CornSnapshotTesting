//
//  CornSnapshotService.swift
//  CornSnapshotTesting
//
//  Created by Marharyta Lytvynenko on 02.11.21.
//  Copyright (c) 2021 Marharyta Lytvynenko. All rights reserved.
//
//  http://www.popcornomnom.com
//

import UIKit
import Vision
import XCTest

/// Single source of truth of handling snapshot asserting.
final class CornSnapshotService {
       
    /// Snapshot file format extension.
    private let fileExtension = "png"
    
    private let artifactsUrl = URL(fileURLWithPath: NSTemporaryDirectory(),
                                   isDirectory: true)

    static let shared = CornSnapshotService()

    // MARK: - Verify Snapshot
      
    public func assertSnapshot(delay: TimeInterval = 1,
                               name: String,
                               path: String,
                               folderComponents: [String] = [],
                               file: String = #file,
                               function: String = #function) {

        let exp = XCTestExpectation(description: "Corn snapshot testing")
        let result = XCTWaiter.wait(for: [exp], timeout: delay)

        guard result == .timedOut else {
            XCTFail("Delay interrupted")
            return
        }
        let snapshot = XCUIApplication().screenshot().image.croppedStatusBar

        var dirUrl = URL(fileURLWithPath: path, isDirectory: true)
            .appendingPathComponent("Snapshots")
        folderComponents.forEach {
            dirUrl.appendPathComponent($0)
        }
        
        let fullname = [name, UIDevice.modelName ].joined(separator: "-").replacingOccurrences(of: " ", with: "-")

        let snapshotFilePath = dirUrl
            .appendingPathComponent(fullname)
            .appendingPathExtension(fileExtension)

        let fileManager = FileManager.default
        try? fileManager.createDirectory(at: dirUrl, withIntermediateDirectories: true)

        guard let referenceData = try? Data(contentsOf: snapshotFilePath),
              let reference = UIImage(data: referenceData, scale: UIScreen.main.scale) else {
            try? snapshot.save(to: snapshotFilePath)

            XCTFail("""
            No reference image was found on a disk.
            Automatically recorded snapshot is available at path: "\(snapshotFilePath.path)"

            Re-run "\(function)" to test against the newly-recorded snapshot.
            """)
            return
        }

        do {
            var diff = Float(0)
            try processImages(reference, snapshot, distance: &diff)

            print("\(name) difference factor: \(diff).")

            guard diff > CornSnapshotConfiguration.current.tolerance else { return }

            let difference = UIImage.diff(reference, snapshot)

            // snapshot name prefix helps to group snapshots of the one test together
            let attachments = [
                XCTAttachment(image: reference, name: "\(name)_reference"),
                XCTAttachment(image: snapshot, name: "\(name)_failure"),
                XCTAttachment(image: difference, name: "\(name)_difference")
            ]

            let artifactsSubUrl = artifactsUrl.appendingPathComponent(fullname)
            try fileManager.createDirectory(at: artifactsSubUrl, withIntermediateDirectories: true)
            let failedSnapshotFileUrl = artifactsSubUrl.appendingPathComponent(snapshotFilePath.lastPathComponent)
            try snapshot.save(to: failedSnapshotFileUrl)

            let message = """
            The snapshot does not match the reference.

            Difference factor: \(diff).

            Refference snapshot:
            \"\(snapshotFilePath.path)\"

            Actual snapshot:
            \"\(failedSnapshotFileUrl.path)\"
            """

            attachments.attachIfNeeded()

            XCTFail(message)

        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

// MARK: - Vision

private extension CornSnapshotService {
    
    /**
     Analyzes the similarity of `reference` and `actual` images using feature print.
     
     A smaller distance value indicates a greater similarity between the images. In case of a 100% match, the distance value is equal `0`.
     
     - Parameters:
        - distance: A pointer to store the calculated distance value.
     */
    func processImages(_ reference: UIImage, _ actual: UIImage, distance: inout Float) throws {
        
        guard let originalFPO = try featurePrintObservationForImage(at: reference) else {
            throw CornSnapshotError.noReferenceFeatureprints
        }
        
        guard let contestantFPO = try featurePrintObservationForImage(at: actual) else {
            throw CornSnapshotError.noActualFeatureprints
        }
        try contestantFPO.computeDistance(&distance, to: originalFPO)
    }
    
    func featurePrintObservationForImage(at image: UIImage) throws -> VNFeaturePrintObservation? {
        guard let cgImage = image.cgImage else {
            throw CornSnapshotError.cgImageDoesNotExist
        }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        do {
            try requestHandler.perform([request])
            return request.results?.first
        } catch {
            throw error
        }
    }
}
