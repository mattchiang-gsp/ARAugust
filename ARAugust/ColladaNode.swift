//
//  VirtualObject.swift
//  ARAugust
//
//  Created by Matthew Chiang on 8/29/18.
//  Copyright © 2018 Matthew Chiang. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

enum HitTestType: Int {
    case lucas = 0b0001
}

class ColladaNode: SCNNode {
    
    convenience init(named name: String) {
        self.init()
        
        guard let scene = SCNScene(named: name) else {
            return
        }
        
        self.name = "lucas"
 
        for childNode in scene.rootNode.childNodes {
            self.addChildNode(childNode)
//            childNode.categoryBitMask = HitTestType.lucas.rawValue
        }
        
        self.categoryBitMask = HitTestType.lucas.rawValue
    }

    public func activate() {
        
        self.scale = SCNVector3(self.scale.x * 2, self.scale.y * 2, self.scale.z * 2)
    }
}
