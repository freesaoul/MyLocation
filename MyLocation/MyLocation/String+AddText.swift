//
//  String+AddText.swift
//  MyLocation
//
//  Created by Anthony Camara on 13/07/2015.
//  Copyright (c) 2015 Anthony Camara. All rights reserved.
//


extension String {
    mutating func addText(text: String?, withSeparator separator: String = "") {
       if let text = text {
            if !isEmpty {
                self += separator
            }
        self += text
        }
    }
}