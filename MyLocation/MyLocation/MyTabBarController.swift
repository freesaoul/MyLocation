//
//  MyTabBarController.swift
//  MyLocation
//
//  Created by Anthony Camara on 13/07/2015.
//  Copyright (c) 2015 Anthony Camara. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
    
}
