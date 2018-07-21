//
//  ViewController.swift
//  PeriodicAR
//
//  Created by Arun Kulkarni on 20/07/18.
//  Copyright © 2018 Arun Kulkarni. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var molecularFormulaLabel: UILabel!
    
    var elementsArray: Array<ElementObject> = []
    var countDict = [String : Int]()
    
    var sessionConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravity
        return configuration
    }()
    
    private var selectedElementColors: [String: UIColor] = [:]
    var parentPostions : [SCNVector3] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.antialiasingMode = .multisampling4X
        sceneView.scene.physicsWorld.contactDelegate = self
        // Set the view's delegate
        sceneView.delegate = self
        
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        if let path = Bundle.main.path(forResource: "ElementList", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .dataReadingMapped)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let elements = jsonResult["elements"] as? [[String: Any]] {
                    
                    for i in 0...(elements.count)-1 {
                        let element = elements[i]
                        let elementObject = ElementObject(name: element["name"] as! String, symbol: element["symbol"] as! String, color: colorWithHexString(hex: element["color"] as! String), xPosition: element["xpos"] as! CGFloat, yPosition: element["ypos"] as! CGFloat)
                        elementsArray.append(elementObject)
                    }
                }
            } catch {
                print(error)
            }
        }
        // addpheres(parentCnt: 3)
    }
    
    func createTable() {
        
        for i in 0...(elementsArray.count - 1)  {
            let box = SCNBox(width: 1, height: 1, length: 0.02, chamferRadius: 0.5)
            let rectangleMaterial = SCNMaterial()
            rectangleMaterial.diffuse.contents = elementsArray[i].color
            box.materials = [rectangleMaterial]
            let boxNode = SCNNode(geometry: box)
            //Fix me
            boxNode.position = SCNVector3(((elementsArray[i].xPosition)) - 10 , -elementsArray[i].yPosition + 5, -10)
            boxNode.name = elementsArray[i].symbol
            sceneView.scene.rootNode.addChildNode(boxNode)
            
            
            let tag = SCNText(string: elementsArray[i].symbol, extrusionDepth: 0.1)
            tag.firstMaterial?.diffuse.contents = UIColor.black
            tag.font = UIFont(name: "Optima", size: 0.5)
            let tagNode = SCNNode(geometry: tag)
            tagNode.position =  SCNVector3Make((boxNode.position.x - Float((box.width/2) - 0.25)), boxNode.position.y - 0.25 - Float(box.height),boxNode.position.z)
            
            self.sceneView.scene.rootNode.addChildNode(tagNode)
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if ARWorldTrackingConfiguration.isSupported {
            self.sceneView.automaticallyUpdatesLighting = true
            sessionConfiguration.isLightEstimationEnabled = true
            self.sceneView.autoenablesDefaultLighting = true
            self.sceneView.session.run(sessionConfiguration)
            UIApplication.shared.isIdleTimerDisabled = true
            
            createTable()
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    @IBAction func resetTapped(_ sender: Any) {
        countDict = [:]
        molecularFormulaLabel.text = ""
    }
    @IBAction func convertTapped(_ sender: Any) {
        didSubmit(with: countDict["C"] ?? 0, hydrogenCount: countDict["H"] ?? 0)
    }
    
    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        return node
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let currentLocation = touch.location(in: sceneView)
            let hitList = sceneView.hitTest(currentLocation, options: nil)
            if let hitObject = hitList.first {
                let node = hitObject.node
                if node.name == "H" {
                    countDict.updateValue(countDict[node.name!] != nil ? countDict[node.name!]! + 1 : 1, forKey: node.name!)
                } else if node.name == "C" {
                    countDict.updateValue(countDict[node.name!] != nil ? countDict[node.name!]! + 1 : 1, forKey: node.name!)
                }
                var molecularText = ""
                if let carbAtom = countDict["C"]{
                    molecularText = "C" + "\(carbAtom)"
                }
                
                if let hydAtom = countDict["H"] {
                    molecularText += "H" + "\(hydAtom)"
                }
                
                molecularFormulaLabel.text = molecularText
               
                molecularFormulaLabel.isHidden = (molecularFormulaLabel.text == "") ? true : false
                selectedElementColors[node.name ?? ""] = (node.geometry?.materials.first?.diffuse.contents as? UIColor ?? .white)
            }
        }
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    private func didSubmit(with carbonCount: Int, hydrogenCount: Int) {
        let maxHydrogenCount = 4
        var bondCount = 0
        if isAlkane(carbonCount: carbonCount, hydrogenCount: hydrogenCount) {
            // Here it's is a single bond
            bondCount = 1
        } else if isAlkene(carbonCount: carbonCount, hydrogenCount: hydrogenCount) {
            // Here it's a double bond
            bondCount = 2
        } else if isAlkyne(carbonCount: carbonCount, hydrogenCount: hydrogenCount) {
            // Here it's a triple bond
            bondCount = 3
        } else {
            print("Invalid strings")
            return
        }
        
        for index in stride(from: 0, to: carbonCount, by: 1) {
            if index == 0 {
                createChildNodes(withChildNodes: Array(repeating: ("H", selectedElementColors["H"] ?? UIColor.white, UIColor.green), count: maxHydrogenCount - bondCount), parentNodeName: "C", parentNodeColor: selectedElementColors["C"] ?? UIColor.white, parentIndex: index)
            } else if index == 1 {
                createChildNodes(withChildNodes: Array(repeating: ("H", selectedElementColors["H"] ?? UIColor.white, UIColor.green), count: maxHydrogenCount - bondCount - 1), parentNodeName: "C", parentNodeColor: selectedElementColors["C"] ?? UIColor.white, parentIndex: index)
            } else if index == (carbonCount - 1) {
                createChildNodes(withChildNodes: Array(repeating: ("H", selectedElementColors["H"] ?? UIColor.white, UIColor.green), count: maxHydrogenCount - bondCount), parentNodeName: "C", parentNodeColor: selectedElementColors["C"] ?? UIColor.white, parentIndex: index)
            } else {
                createChildNodes(withChildNodes: Array(repeating: ("H", selectedElementColors["H"] ?? UIColor.white, UIColor.green), count: 2), parentNodeName: "C", parentNodeColor: selectedElementColors["C"] ?? UIColor.white, parentIndex: index)
            }
        }
        
        updateParentNodes(withNodeCount: carbonCount)
    }
    
    private func updateParentNodes(withNodeCount nodeCount: Int) {
        for index in stride(from: 0, to: nodeCount - 1, by: 1) {
            
            let carbonCount = countDict["C"] ?? 0
            let hydrogenCount = countDict["H"] ?? 0
            if isAlkane(carbonCount: carbonCount, hydrogenCount: hydrogenCount) {
                // Here it's is a single bond
                updateNode(atIndex: index, endIndex: index + 1, bondColor: UIColor.green)
            } else if isAlkene(carbonCount: carbonCount, hydrogenCount: hydrogenCount) {
                // Here it's a double bond
                updateNode(atIndex: index, endIndex: index + 1, bondColor: UIColor.blue)
            } else if isAlkyne(carbonCount: carbonCount, hydrogenCount: hydrogenCount) {
                // Here it's a triple bond
                updateNode(atIndex: index, endIndex: index + 1, bondColor: UIColor.red)
            }
        }
    }
    
    private func createChildNodes(withChildNodes nodes: [(nodeName: String?, nodeColor: UIColor, bondColor: UIColor)], parentNodeName: String?, parentNodeColor: UIColor,parentIndex:Int) {
        addSpheres(withChildNodes: nodes, parentNodeName: parentNodeName, parentNodeColor: parentNodeColor, parentIndex: parentIndex)
    }
    
    private func updateNode(atIndex startIndex: Int, endIndex: Int, bondColor: UIColor) {
    
                let linenode = Cylinder(startPoint:parentPostions[startIndex], endPoint: parentPostions[endIndex], radius: 0.2, radSegmentCount: 0, color: bondColor)
                self.sceneView.scene.rootNode.addChildNode(linenode)
       
    }
}

extension ViewController {
    func isAlkane(carbonCount: Int, hydrogenCount: Int) -> Bool {
        // 2n+2 for alkane
        return (hydrogenCount == (2 * carbonCount + 2))
    }
    
    func isAlkene(carbonCount: Int, hydrogenCount: Int) -> Bool {
        // 2n for alkene
        return (hydrogenCount == (2 * carbonCount))
    }
    
    func isAlkyne(carbonCount: Int, hydrogenCount: Int) -> Bool {
        // 2n-2 for alkyne
        return (hydrogenCount == (2 * carbonCount - 2))
    }
}

extension ViewController {
    
    func getChildVectors(childCount:Int) -> [SCNMatrix4]{
        var childAngles :[SCNMatrix4] = []
        let kDefaultAngle =  Float(360 / childCount)
        var baseAngle : Float = kDefaultAngle
        var count = childCount
        while count > 0 {
            baseAngle = baseAngle + kDefaultAngle
            childAngles.append(getTransform(angle:baseAngle))
            count = count - 1
        }
        return childAngles
    }
    
    func getTransform(angle:Float) -> SCNMatrix4 {
        let distance = 0.15
        //let distance = BearAngle.distanceTwopoints(map1: currentLocation, map2: endLocation)
        
        let translation = SCNMatrix4MakeTranslation(0, -0.15, Float(-distance))
        // Rotate (yaw) around y axis
        let rotation = SCNMatrix4MakeRotation(-1 * GLKMathDegreesToRadians(angle), 0, 1, 0)
        
        let transform = SCNMatrix4Mult(translation, rotation)
        
        return transform
    }
    func getTextNode(text:String,pos : SCNVector3) -> SCNNode {
        let textBlock = SCNText(string: text, extrusionDepth: 0.1)
        textBlock.font = UIFont(name: "Optima", size: 0.05)
        //textBlock.flatness = -2.0
        textBlock.firstMaterial?.diffuse.contents = UIImage(named: "texture.png") //UIColor.white
        textBlock.alignmentMode = kCAAlignmentCenter
        let textNode = SCNNode(geometry: textBlock)
        textNode.position = pos //SCNVector3(0,-0.01,0)
        //textNode.scale = SCNVector3Make( 0.2, 0.2, 0.2);
        return textNode
    }
    func addSpheres(withChildNodes nodes: [(nodeName: String?, nodeColor: UIColor, bondColor: UIColor)], parentNodeName: String?, parentNodeColor: UIColor,parentIndex:Int){
        
        let firstnode = SCNNode(geometry: getSphere(text: parentNodeName ?? "", color: parentNodeColor))
        firstnode.light = getLight()
        firstnode.position = SCNVector3(-0.25 * Double(parentIndex),0,-0.5)
        parentPostions.append(firstnode.position)
        self.sceneView.scene.rootNode.addChildNode(firstnode)
        // firstnode.addChildNode(getTextNode(text: "C", pos: firstnode.position))
        for (index , childAngle) in getChildVectors(childCount: nodes.count).enumerated() {
            let childNode = SCNNode(geometry: getSphere(text: nodes[index].nodeName ?? "", color: nodes[index].nodeColor))
            childNode.light = getLight()
            childNode.transform = childAngle
            firstnode.addChildNode(childNode)
            let pointTransform = childNode.worldTransform //turns the point into a point on the world grid
            let pointVector = SCNVector3Make(pointTransform.m41, pointTransform.m42, pointTransform.m43)
            //   this is used for single line             self.sceneView.scene.rootNode.addChildNode(firstnode.position.line(to: pointVector, color: .black))
            let linenode = Cylinder(startPoint:firstnode.position, endPoint: pointVector, radius: 0.2, radSegmentCount: 0, color: nodes[index].bondColor)
            self.sceneView.scene.rootNode.addChildNode(linenode)
            //  childNode.addChildNode(getTextNode(text: "H", pos: childNode.position))
        }

    }
    
    func getLight() -> SCNLight {
        // Create shadow
        let spotLight = SCNLight()
        spotLight.type = .omni
        spotLight.spotInnerAngle = 30.0
        spotLight.spotOuterAngle = 80.0
        return spotLight
    }
    
    func getSphere(text: String,color:UIColor) -> SCNSphere{
        let sphere = SCNSphere(radius: 0.05)
        // sphere.firstMaterial?.diffuse.contents = UIColor.red
        let firstmat = SCNMaterial()
        firstmat.diffuse.contents = createSnapshotView(text:text,color: color)
        firstmat.lightingModel = .constant
        firstmat.isDoubleSided = true
        let secondMat = SCNMaterial()
        secondMat.diffuse.contents = createSnapshotView(text:text,color: color)
        secondMat.lightingModel = .constant
        secondMat.isDoubleSided = true
        
        sphere.materials = [firstmat,secondMat]
        //        sphere.firstMaterial?.diffuse.contents =  // UIImage(named: <#T##String#>//
        //        sphere.firstMaterial?.lightingModel = .constant
        //        sphere.firstMaterial?.isDoubleSided = true
        return sphere
    }
    func createSnapshotView(text:String,color:UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 300, height: 300)
        let snapView  = UIView(frame: rect)
        snapView.backgroundColor = color
        let textRect = CGRect(x:0, y: 0, width: 150, height: 300)
        let seclabel = UILabel(frame:  CGRect(x: 150, y: 0, width: 150, height: 300))
        seclabel.textAlignment = .center
        seclabel.font = UIFont(name: "Optima", size: 35.0)
        seclabel.text = text
        let label = UILabel(frame: textRect)
        label.textAlignment = .center
        label.font = UIFont(name: "Optima", size: 35.0)
        label.text = text
        snapView.addSubview(label)
        snapView.addSubview(seclabel)
        return snapView.snapshotImage()
    }
}
extension UIView{
    func snapshotImage(afterScreenUpdates: Bool = true) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        self.drawHierarchy(in: self.frame, afterScreenUpdates: afterScreenUpdates)
        let snapShotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapShotImage ?? UIImage()
    }
}
