//
//  Location.swift
//  MyLocation
//
//  Created by Anthony Camara on 09/07/2015.
//  Copyright (c) 2015 Anthony Camara. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

class Location: NSManagedObject, MKAnnotation {

// MARK: - Property
    
    @NSManaged var category:            String
    @NSManaged var date:                NSDate
    @NSManaged var latitude:            Double
    @NSManaged var locationDescription: String
    @NSManaged var longitude:           Double
    @NSManaged var placemark:           CLPlacemark?
    @NSManaged var photoID:             NSNumber?
    
    var hasPhoto:   Bool {
        return photoID != nil
    }
    var photoPath:  String {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.integerValue).jpg"
        return applicationDocumentsDirectory.stringByAppendingPathComponent(filename)
    }
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoPath)
    }
    
    
    class func nextPhotoID() -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentID = userDefaults.integerForKey("photoID")
        userDefaults.setInteger(currentID + 1, forKey: "photoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile() {
        if hasPhoto {
            let path = photoPath
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(path) {
                var error: NSError?
                if !fileManager.removeItemAtPath(path, error: &error) {
                    println("Error removing file: \(error!)")
                }
            }
        }
    }
    
// MARK: - MKAnnotation Protocol
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
   
    var title: String! {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    var subtitle: String! {
        return category
    }
    
}
