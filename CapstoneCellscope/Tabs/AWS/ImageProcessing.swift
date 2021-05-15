//
//  ImageProcessing.swift
//  Cellscope
//
//  Created by marcos joel gonzález on 5/8/21.
//

import Foundation
import SwiftUI
import SwiftImage
import MetalPerformanceShaders


func brightfieldProcessing(image1: UIImage, image2: UIImage) -> UIImage {

    let result = OpenCVWrapper.brightfield(image1, andImage2: image2)
    
    ImageSaver().writeToPhotoAlbum(image: result)

    print("-----Brightfield processing DONE-----")
    
    return result
}


func differentialPhaseContrastProcessing(image1: UIImage, image2: UIImage) -> UIImage {
    
    let result = OpenCVWrapper.dpc(image1, andImage2: image2)
    
    ImageSaver().writeToPhotoAlbum(image: result)

    print("-----Brightfield processing DONE-----")
    
    return result
    
}

func thresholdingProcessing(image: UIImage) -> UIImage {
    
    let result = OpenCVWrapper.thresholding(image)
    
    ImageSaver().writeToPhotoAlbum(image: result)
    
    print("-----Thresholding processing DONE-----")
    
    return result
}

func convolutionProcessing(image: UIImage) -> UIImage {
    
    let result = OpenCVWrapper.convolve(image)
    
    ImageSaver().writeToPhotoAlbum(image: result)
    
    print("-----Convolution processing DONE-----")
    
    return result
}

func fourierProcessing(image: UIImage) -> UIImage {
    
    let result = OpenCVWrapper.fourier(image)
    
    ImageSaver().writeToPhotoAlbum(image: result)
    
    print("-----Fourier Transform processing DONE-----")
    
    return result
}

//    func textToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> UIImage{
//
//        let canvas = CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height)
//        inImage.draw(in: canvas)
//
//        // Setup the font specific variables
//        var textColor = UIColor.white
//        var textFont = UIFont(name: "Helvetica Bold", size: 12)!
//
//        // Setup the image context using the passed image
//        let scale = UIScreen.mainScreen().scale
//        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
//
//        // Setup the font attributes that will be later used to dictate how the text should be drawn
//        let textFontAttributes = [
//            NSFontAttributeName: textFont,
//            NSForegroundColorAttributeName: textColor,
//        ]
//
//        // Put the image into a rectangle as large as the original image
//        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
//
//        // Create a point within the space that is as bit as the image
//        var rect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
//
//        // Draw the text into an image
//        drawText.drawInRect(rect, withAttributes: textFontAttributes)
//
//        // Create a new image out of the images we have created
//        var newImage = UIGraphicsGetImageFromCurrentImageContext()
//
//        // End the context now that we have the image we need
//        UIGraphicsEndImageContext()
//
//        //Pass the image back up to the caller
//        return newImage
//    }

