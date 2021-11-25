//
//  CIImageExtension.swift
//  CornSnapshotTesting
//
//  Created by Marharyta Lytvynenko on 18.11.21.
//  Copyright (c) 2021 Marharyta Lytvynenko. All rights reserved.
//
//  http://www.popcornomnom.com
//
import UIKit

import CoreImage
import CoreImage.CIFilterBuiltins

@available(iOS 14.0, *)
extension CIImage {
    
    /// Uses `gaussianBlur` filter.
    func blurred(_ radius: Float) -> CIImage? {
        let filter = CIFilter.gaussianBlur()
        filter.radius = radius
        filter.inputImage = self
        return filter.outputImage
    }
    
    func filtered(contrast: Float = 1,
                  brightness: Float = 0,
                  saturation: Float = 1) -> CIImage? {
        let filter = CIFilter.colorControls()
        filter.inputImage = self
        filter.contrast = contrast
        filter.brightness = brightness
        filter.saturation = saturation
        return filter.outputImage
    }
    
    /// Uses `maskToAlpha` filter.
    var withoutBackground: CIImage? {
        let filter = CIFilter.maskToAlpha()
        filter.inputImage = self
        return filter.outputImage
    }
    
    /// Returns absolute difference of two images.
    static func difference(_ first: CIImage, _ second: CIImage) -> CIImage? {
        let filter = CIFilter.colorAbsoluteDifference()
        filter.inputImage = first
        filter.inputImage2 = second
        return filter.outputImage
    }
    
    /// Blends `backgroundImage` and `overlayImage` using `maskImage`.
    static func blended(
        backgroundImage: CIImage,
        overlayImage: CIImage,
        maskImage: CIImage)
    -> CIImage? {
        let filter = CIFilter.blendWithMask()
        filter.backgroundImage = backgroundImage
        filter.maskImage = maskImage
        filter.inputImage = overlayImage
        return filter.outputImage
    }
}
