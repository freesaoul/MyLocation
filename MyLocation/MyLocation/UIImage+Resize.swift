//
//  UIImage+Resize.swift
//  MyLocation
//
//  Created by Anthony Camara on 10/07/2015.
//  Copyright (c) 2015 Anthony Camara. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImagedWithBounds(bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRation = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRation)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        drawInRect(CGRect(origin: CGPoint.zeroPoint, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
