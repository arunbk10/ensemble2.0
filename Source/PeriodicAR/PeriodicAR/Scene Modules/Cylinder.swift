//
//  Cylinder.swift
//  PeriodicAR
//
//  Created by Sharanabasappa-Macmini on 21/07/18.
//  Copyright © 2018 Arun Kulkarni. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Cylinder: SCNNode {
    
    
    init(startPoint: SCNVector3,
         endPoint: SCNVector3,
         radius: CGFloat,
         radSegmentCount: Int,
         color: UIColor)
    {
        super.init()
        self.name = "LineNode"
        //Calcul the height of our line
        let height = startPoint.distance(from: endPoint)
        
        //set position to v1 coordonate
        position = (startPoint + endPoint) / 2
        eulerAngles = SCNVector3.lineEulerAngles(vector: endPoint - startPoint)
        let cylinder =  SCNCylinder(radius: 0.01, height: CGFloat(height))
        cylinder.firstMaterial?.diffuse.contents = color
        self.geometry = cylinder
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

