//
//  ElelmentObject.swift
//  PeriodicAR
//
//  Created by Deepa on 20/07/18.
//  Copyright © 2018 Arun Kulkarni. All rights reserved.
//

import Foundation
import UIKit

class ElementObject {
    var name: String
    var symbol: String
    var color: UIColor
    var xPosition: CGFloat = 0.0
    var yPosition: CGFloat = 0.0
    
    init(name: String, symbol: String, color: UIColor, xPosition: CGFloat, yPosition: CGFloat) {
        self.name = name
        self.symbol = symbol
        self.color = color
        self.xPosition = xPosition
        self.yPosition = yPosition
    }
    
}
