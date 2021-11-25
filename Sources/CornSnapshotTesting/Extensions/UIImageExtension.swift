//
//  UIImageExtension.swift
//  CornSnapshotTesting
//
//  Created by Marharyta Lytvynenko on 02.11.21.
//  Copyright (c) 2021 Marharyta Lytvynenko. All rights reserved.
//
//  http://www.popcornomnom.com
//

import UIKit
import CoreImage

extension UIImage {
    func save(to url: URL) throws {
        guard let pngData = pngData() else { return }
        try pngData.write(to: url)
    }
    
    // MARK: - Images difference
    
    /// Returns the difference image between `first` and `second` images.
    class func diff(_ first: UIImage, _ second: UIImage) -> UIImage {
        if #available(iOS 14.0, *), let difference = blendWithMaskDifference(first, second) {
            return difference
        } else {
            return colorBlendModeDifference(first, second)
        }
    }
    
    /**
     Compares two images in a more aggressive way than ``colorBlendModeDifference``.
     `blendWithMaskDifference` reduces the noise of each image and makes it more contrast before comparison.
     - Parameters:
        - first: The first image to compare.
        - second: The second image to compare.
        - highlighterColor: The color used to highlight the areas of difference between  two snapshots. To change this color check the ``CornSnapshotConfiguration/highlighterColor``.
     - Returns: The difference image.
     */
    @available(iOS 14.0, *)
    private class func blendWithMaskDifference(
        _ first: UIImage,
        _ second: UIImage,
        highlighterColor: CIColor = CornSnapshotConfiguration.current.highlighterColor
    ) -> UIImage? {
        func processed(_ ciImage: CIImage) -> CIImage? {
            ciImage
                .blurred(0.8)?
                .filtered(contrast: 10, brightness: 10, saturation: 10)
        }
        guard
            let ciFirstOriginal = CIImage(image: first),
            let ciFitstProcessed = processed(ciFirstOriginal),
            let ciSecondOriginal = CIImage(image: second),
            let ciSecondProcessed = processed(ciSecondOriginal)
        else {
            print("Couldn't process images 🥺")
            return nil
        }
        
        guard
            let backgroundImage = ciFirstOriginal.filtered(brightness: -0.996),
            let differenceImage = CIImage.difference(ciFitstProcessed, ciSecondProcessed),
            let maskImage = differenceImage.withoutBackground,
            let overlayImage = CIImage(color: highlighterColor).filtered(contrast: 3,
                                                                        brightness: 10,
                                                                        saturation: 10),
            let resultImage = CIImage.blended(backgroundImage: backgroundImage,
                                              overlayImage: overlayImage,
                                              maskImage: maskImage),
            let cgImage = CIContext().createCGImage(resultImage, from: resultImage.extent)
        else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// Compares two images using `image.draw(at point:blendMode:alpha:)`.
    /// - Returns: The difference image.
    private class func colorBlendModeDifference(_ first: UIImage, _ second: UIImage) -> UIImage {
        let width = max(first.size.width, second.size.width)
        let height = max(first.size.height, second.size.height)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, 0)
        second.draw(at: .zero)
        first.draw(at: .zero, blendMode: .difference, alpha: 0.95)
        let difference = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return difference
    }
    
    // MARK: - Status bar
    
    var croppedStatusBar: UIImage {
        // Using deprecated method because
        // `UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        // .windowScene?.statusBarManager?.statusBarFrame.height` returns `nil`
        // because `UIApplication.shared.windows` array is empty
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let size = CGSize(width: self.size.width, height: self.size.height - statusBarHeight)
        
        let rect = CGRect(origin: CGPoint(x: 0, y: statusBarHeight), size: size)
        return cropped(rect: rect)
    }
    
    func cropped(rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x *= scale
        rect.origin.y *= scale
        rect.size.width *= scale
        rect.size.height *= scale
        
        let imageRef = cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: scale, orientation: imageOrientation)
        return image
    }
}
