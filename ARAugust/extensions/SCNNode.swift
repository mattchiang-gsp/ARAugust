//
//  SCNNode.swift
//  ARAugust
//
//  Created by Matthew Chiang on 8/29/18.
//  Copyright © 2018 Matthew Chiang. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    func parentWithName(_ name: String) -> SCNNode?{
        
        var currentNode: SCNNode? = self.parent
        
        while currentNode != nil {
            
            if (currentNode!.name == name) {
                return currentNode
            }
            
            currentNode = currentNode!.parent
        }
        
        return nil
    }
}
