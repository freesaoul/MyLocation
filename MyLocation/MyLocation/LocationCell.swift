//
//  LocationCell.swift
//  MyLocation
//
//  Created by Anthony Camara on 10/07/2015.
//  Copyright (c) 2015 Anthony Camara. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
// MARK: - IBOutlet

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
 
// MARK: - Configure Cell
    
    func configureForLocation(location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            addressLabel.text = "\(placemark.subThoroughfare), \(placemark.thoroughfare)," +
                                "\(placemark.locality)"
        } else {
            addressLabel.text = String(format: "Lat:%.8f Long:%.8f", location.latitude, location.longitude)
        }
        photoImageView.image = imageForLocation(location)
    }
    
    func imageForLocation(location: Location) -> UIImage {
        if location.hasPhoto {
            if let image = location.photoImage {
                return image.resizedImagedWithBounds(CGSize(width: 52, height: 52))
            }
        }
        return UIImage()
    }
    
}
