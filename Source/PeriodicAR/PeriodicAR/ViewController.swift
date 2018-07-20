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
    var skScene = SKScene()
    var arrayElements = ["A", "H", "C", "B"]
    
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
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    func createTable() {
        for i in 0...3 {
            let box = SCNBox(width: 1, height: 1, length: 0.01, chamferRadius: 0)
            let rectangleMaterial = SCNMaterial()
            rectangleMaterial.diffuse.contents = UIColor.gray
            box.materials = [rectangleMaterial]
            let boxNode = SCNNode(geometry: box)
            boxNode.position = SCNVector3(-CGFloat(i) * 1.15,0,-5)
            boxNode.name = arrayElements[i]
            sceneView.scene.rootNode.addChildNode(boxNode)
            
            let textposition = SCNVector3Make(Float(i), 0,-1)
            let textNode = self.addText(text: arrayElements[i], position: textposition,color: UIColor.gray)
            let textMaterials = SCNMaterial()
            textMaterials.diffuse.contents = textNode
            boxNode.eulerAngles.z = Float.pi / 2
            box.materials = [textMaterials]
        }
    }
    
    func addText(text: String, position: SCNVector3,color: UIColor)->SKScene {
        skScene = SKScene(size: CGSize(width: 200, height: 200))
        skScene.backgroundColor = color
        let labelNode = SKLabelNode(text: text)
        labelNode.fontSize = 30
        labelNode.color = UIColor.red
        labelNode.fontColor = UIColor.red
        labelNode.fontName = "Kailasa"
        labelNode.zRotation = .pi/2
        labelNode.yScale = -1
        labelNode.position = CGPoint(x:100,y:100)
        skScene.addChild(labelNode)
        
        return skScene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            self.sceneView.automaticallyUpdatesLighting = true
            sessionConfiguration.isLightEstimationEnabled = true
            self.sceneView.autoenablesDefaultLighting = true
            self.sceneView.session.run(configuration)
            createTable()
            UIApplication.shared.isIdleTimerDisabled = true
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
}
