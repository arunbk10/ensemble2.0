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
    var arrayElements = ["A", "H", "C", "B"]
    var elementsArray: Array<City> = []
    
    var sessionConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        return configuration
    }()
    
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
                        print(colorWithHexString(hex: element["color"] as! String))
                        let city = City(name: element["name"] as! String, symbol: element["symbol"] as! String, color: colorWithHexString(hex: element["color"] as! String), xPosition: element["xpos"] as! CGFloat)
                        elementsArray.append(city)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    func createTable() {
        for i in 0...(elementsArray.count - 1)  {
            let box = SCNBox(width: 1, height: 1, length: 0.01, chamferRadius: 0)
            let rectangleMaterial = SCNMaterial()
            rectangleMaterial.diffuse.contents = elementsArray[i].color
            box.materials = [rectangleMaterial]
            let boxNode = SCNNode(geometry: box)
            //Fix me
            boxNode.position = SCNVector3(elementsArray[i].xPosition,0,-5)
            boxNode.name = elementsArray[i].symbol
            sceneView.scene.rootNode.addChildNode(boxNode)
            
            let textposition = SCNVector3Make(Float(i), 0,-1)
            let textNode = addText(text: elementsArray[i].symbol, position: textposition,color: elementsArray[i].color)
            let textMaterials = SCNMaterial()
            textMaterials.diffuse.contents = textNode
            box.materials = [textMaterials]
        }
    }
    
    func addText(text: String, position: SCNVector3,color: UIColor)->SKScene {
        let skScene = SKScene(size: CGSize(width: 200, height: 200))
        skScene.backgroundColor = color
        let labelNode = SKLabelNode(text: text)
        labelNode.fontSize = 30
        labelNode.color = UIColor.red
        labelNode.fontColor = UIColor.red
        labelNode.yScale = -1
        labelNode.position = CGPoint(x:skScene.size.width/2,y:skScene.size.height/2)
        skScene.addChild(labelNode)
        
        return skScene
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
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
                print(node.name ?? "")
            }
        }
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.characters.count != 6) {
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
}
