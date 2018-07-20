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
    }
    
    func createTable() {
        for i in 0...3 {
            let box = SCNBox(width: 1, height: 1, length: 0.01, chamferRadius: 0)
            let rectangleMaterial = SCNMaterial()
            rectangleMaterial.diffuse.contents = UIColor.gray
            box.materials = [rectangleMaterial]
            let boxNode = SCNNode(geometry: box)
            //Fix me
            boxNode.position = SCNVector3(CGFloat(i)*1.05,0,-5)
            boxNode.name = arrayElements[i]
            sceneView.scene.rootNode.addChildNode(boxNode)
            
            let textposition = SCNVector3Make(Float(i), 0,-1)
            let textNode = addText(text: arrayElements[i], position: textposition,color: UIColor.gray)
            let textMaterials = SCNMaterial()
            textMaterials.diffuse.contents = textNode
            box.materials = [textMaterials]
        }
    }
    
    func addText(text: String, position: SCNVector3,color: UIColor)->SKScene {
        let skScene = SKScene(size: CGSize(width: 200, height: 200))
        skScene.backgroundColor = UIColor.gray
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
}
