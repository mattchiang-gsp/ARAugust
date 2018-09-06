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
        
        // Add tapGestureRecognizer to the view controller
        addTapGestureToSceneView()
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
        
        // Tell ARKit to look for horizontal planes
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    // MARK: - Plane Detection
    /*
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1. Unwrap anchor as an ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 2. Create the SCNPlane
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // 3. Set plane materials
        plane.materials.first?.diffuse.contents = UIColor.blue
        
        // 4. Create a node with the plane geometry
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        planeNode.eulerAngles.x = -Float.pi/2
        
        node.addChildNode(planeNode)
    }
    */
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1. Extract previous ARPlaneAnchor, SCNNode, and SCNplane
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 2. Update plane's width and height
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3. Update planeNode's position
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
 
    // MARK: - Image Recognition
    /*
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return
        }
        
        /*
        // 1. Load the plane's scene
        guard let shipScene = SCNScene(named: "art.scnassets/ship.scn") else {
            print("Cannot find ship scene in art.scnassets")
            return
        }
     
        print("Should load lucas")
     
        let shipNode = shipScene.rootNode.childNode(withName: "lucas", recursively: true)!
     
        
        guard let scene = SCNScene(named: "FitLucas00out.dae") else {
            return
        }
        
        let shipNode = SCNNode()
 
        
        let nodeArray = scene.rootNode.childNodes
        
        for childNode in nodeArray {
            shipNode.addChildNode(childNode as SCNNode)
        }
         */
        
        let lucasNode = ColladaNode(named: "FitLucas00out.dae")
        
        
        // 2. Calculate the size based on shipNode's bounding box
        let (min, max) = lucasNode.boundingBox
        let size = SCNVector3Make(max.x - min.x, max.y - min.y, max.z - min.z)
        
        // 3. Calculate the ratio of difference between real image and object size.
        // Ignore Y axis because it will be pointed out of the image
        let widthRatio = Float(imageAnchor.referenceImage.physicalSize.width) / size.x
        let heightRatio = Float(imageAnchor.referenceImage.physicalSize.height) / size.z
        let scale = [widthRatio, heightRatio].min()!
        // 4. Set transform from imageAnchor data
        lucasNode.transform = SCNMatrix4(imageAnchor.transform)
        
        lucasNode.scale = SCNVector3(scale, scale, scale)
        
        // 5. Add the node to the scene
        // sceneView.scene.rootNode.addChildNode(shipNode)
        sceneView.scene.rootNode.addChildNode(lucasNode)
    }
    */
    // MARK: - Combined plane and image detection
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if let detectedAnchor = anchor as? ARImageAnchor {
            print("It's an image")
            spawnModelOnImageAnchor(imageAnchor: detectedAnchor)
        } else if let detectedAnchor = anchor as? ARPlaneAnchor {
            print("It's a horizontal plane. Tap gesture handles spawning models on the plane")
        } else {
            print("Nothing")
        }
    }
    
    func spawnModelOnImageAnchor(imageAnchor: ARImageAnchor) {
        let lucasNode = ColladaNode(named: "FitLucas00out.dae")
        
        // 2. Calculate the size based on shipNode's bounding box
        let (min, max) = lucasNode.boundingBox
        let size = SCNVector3Make(max.x - min.x, max.y - min.y, max.z - min.z)
        
        // 3. Calculate the ratio of difference between real image and object size.
        // Ignore Y axis because it will be pointed out of the image
        let widthRatio = Float(imageAnchor.referenceImage.physicalSize.width) / size.x
        let heightRatio = Float(imageAnchor.referenceImage.physicalSize.height) / size.z
        let scale = [widthRatio, heightRatio].min()!
        // 4. Set transform from imageAnchor data
        lucasNode.transform = SCNMatrix4(imageAnchor.transform)
        
        lucasNode.scale = SCNVector3(scale, scale, scale)
        
        // 5. Add the node to the scene
        // sceneView.scene.rootNode.addChildNode(shipNode)
        sceneView.scene.rootNode.addChildNode(lucasNode)
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
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        // guard let sceneView = sender.view as? ARSCNView else { return }
        let tapLocation = sender.location(in: sceneView)
        
        
        let hitTestResult = sceneView.hitTest(tapLocation, options: [SCNHitTestOption.categoryBitMask : HitTestType.lucas.rawValue] )
        if !hitTestResult.isEmpty {
          
            if var lucas = hitTestResult.first!.node.parentWithName("lucas") {
                (lucas as! ColladaNode).activate()
            } else {
                // Add Lucas to the plane. Lucas only be added on a plane
                addLucasToSceneView(tapLocation: tapLocation)
            }
            
        }
    }
    
    // Spawn the model a set distance away from the camera
    func spawnModel() {
        let offsetPosition = SCNVector3(x: 0, y: 0, z: -1)
        let objectPosition = sceneView.pointOfView!.convertPosition(offsetPosition, to: nil)
        
        let lucasNode = ColladaNode(named: "FitLucas00out.dae")
        
        // 1. Add model to the scene
        lucasNode.scale = SCNVector3(0.01, 0.01, 0.01)
        lucasNode.position = objectPosition
        lucasNode.rotation.x = 0
        sceneView.scene.rootNode.addChildNode(lucasNode)
    }
    
    // Spawn the model where the tap occured on the horizontal plane
    func addLucasToSceneView(tapLocation: CGPoint) {
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        // Get the x, y, and z from the tap location of the existing plane
        guard let hitTestResult = hitTestResults.first else { return }
        
        let translation = hitTestResult.worldTransform.columns.3
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        // TODO: - Turn spawnModel into a general function
        let lucasNode = ColladaNode(named: "FitLucas00out.dae")
        lucasNode.scale = SCNVector3(0.01, 0.01, 0.01)
        lucasNode.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(lucasNode)
    }
    
    
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    // MARK: - ARSCNViewDelegate
    
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
