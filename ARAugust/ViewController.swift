//
//  ViewController.swift
//  ARAugust
//
//  Created by Matthew Chiang on 8/28/18.
//  Copyright © 2018 Matthew Chiang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var shipNode: SCNNode?
    var imageNode: SCNNode?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
        
        // Add tapGestureRecognizer to the view controller
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load reference images to look for from "AR Resources" folder
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Add previously loaded images to ARscene configuration as detectionimages
        configuration.detectionImages = referenceImages

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return
        }
        
        // 1. Load the plane's scene
//        guard let shipScene = SCNScene(named: "art.scnassets/ship.scn") else {
//            print("Cannot find ship scene in art.scnassets")
//            return
//        }
        
//        print("Should load lucas")
        
//        let shipNode = shipScene.rootNode.childNode(withName: "lucas", recursively: true)!
       
        
        guard let scene = SCNScene(named: "FitLucas00out.dae") else {
            return
        }
        
        let shipNode = SCNNode()
        
        let nodeArray = scene.rootNode.childNodes
        
        for childNode in nodeArray {
            shipNode.addChildNode(childNode as SCNNode)
        }
        
        // 2. Calculate the size based on shipNode's bounding box
        let (min, max) = shipNode.boundingBox
        let size = SCNVector3Make(max.x - min.x, max.y - min.y, max.z - min.z)
        
        // 3. Calculate the ratio of difference between real image and object size.
        // Ignore Y axis because it will be pointed out of the image
        let widthRatio = Float(imageAnchor.referenceImage.physicalSize.width) / size.x
        let heightRatio = Float(imageAnchor.referenceImage.physicalSize.height) / size.z
        let scale = [widthRatio, heightRatio].min()!
        // 4. Set transform from imageAnchor data
        shipNode.transform = SCNMatrix4(imageAnchor.transform)
        
        shipNode.scale = SCNVector3(scale, scale, scale)
        
        // 5. Add the node to the scene
        sceneView.scene.rootNode.addChildNode(shipNode)
        
//        self.imageNode = node
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
    
    // MARK: - Touch Gestures
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
//        self.spawnModel()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        // guard let sceneView = sender.view as? ARSCNView else { return }
        let touchLocation = sender.location(in: sceneView)
        
        
        let hitTestResult = sceneView.hitTest(touchLocation, options: [SCNHitTestOption.categoryBitMask : HitTestType.lucas.rawValue] )
        if !hitTestResult.isEmpty {
          
            
            if var lucas = hitTestResult.first!.node.parentWithName("lucas") {
                (lucas as! ColladaNode).activate()
            }
            
            
            
            
//            for hitResult in hitTestResult {
//
//                print(hitResult.node.name)
//                print("----")
////                if (hitResult.node.parent != nil) {
////                    print(hitResult.node.parent?.name)
////                }
////                hitResult.node.scale = SCNVector3(4, 4, 4)
//            }
//            print(">>>>>>>>")
        } else {
            self.spawnModel()
        }
    }
    
   
    
    func spawnModel() {
        let offsetPosition = SCNVector3(x: 0, y: 0, z: -1)
        let objectPosition = sceneView.pointOfView!.convertPosition(offsetPosition, to: nil)
        
        
        
        let lucasNode = ColladaNode(named: "FitLucas00out.dae")
        
        
        
        
        
//        guard let scene = SCNScene(named: "FitLucas00out.dae") else {
//            return
//        }
        
//        let modelNode = SCNNode()
//        let nodeArray = scene.rootNode.childNodes
//        for childNode in nodeArray {
//            modelNode.addChildNode(childNode as SCNNode)
//        }
//
        // 1. Add model to the scene
        lucasNode.scale = SCNVector3(0.01, 0.01, 0.01)
        lucasNode.position = objectPosition
        lucasNode.rotation.x = 0
        sceneView.scene.rootNode.addChildNode(lucasNode)
        
    }
    
//    private func objectInteracting(with gesture: UIGestureRecognizer, in view: ARSCNView) {
//        for index in 0..<gesture.numberOfTouches {
//            let touchLocation = gesture.location(ofTouch: index, in: view)
//
//            print(touchLocation)
//        }
//    }
    
    

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
