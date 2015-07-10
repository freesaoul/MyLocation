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

class Location: NSManagedObject {

// MARK: - Property
    
    @NSManaged var category: String
    @NSManaged var date: NSDate
    @NSManaged var latitude: Double
    @NSManaged var locationDescription: String
    @NSManaged var longitude: Double
    @NSManaged var placemark: CLPlacemark?

}
