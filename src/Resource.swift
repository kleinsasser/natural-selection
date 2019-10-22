//
//  Resource.swift
//  Natural Selection
//
//  Created by Maxwell Kleinsasser on 12/27/18.
//  Copyright © 2018 Maxwell Kleinsasser. All rights reserved.
//
//  File contains the Resource class, inherits from the Detectable class
//  so nodes can "detect" resource objects. Resources are the little
//  brown dots that Nodes need to survive.

import Foundation
import SpriteKit
import GameplayKit

var numResources : Int = 0

public class Resource : Detectable {
    
    static var random = GKRandomSource()
    static var resourceIndex : Int = 0
    
    init(scene: SKScene) {
        
        super.init(texture: SKTexture(imageNamed: "Resource.png"), color: .white, size: CGSize(width: 8, height: 8))
        
        self.quad = Quad(self)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.contactTestBitMask = 1
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = 0
        
        self.name = "R\(Resource.resourceIndex)"
        Resource.resourceIndex += 1
        
        self.position = CGPoint(x: CGFloat.random(in: -Config.sceneWidth / 2...Config.sceneWidth / 2), y: CGFloat.random(in: -Config.sceneHeight / 2...Config.sceneHeight / 2))
        
        numResources += 1
        allDetectables.updateValue(self, forKey: name!)
        scene.addChild(self)
    }
    
    init(scene: SKScene, position: CGPoint) {
        super.init(texture: SKTexture(imageNamed: "Resource.png"), color: .white, size: CGSize(width: 8, height: 8))
        
        self.quad = Quad(self)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.contactTestBitMask = 1
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = 0
        
        self.name = "R\(Resource.resourceIndex)"
        Resource.resourceIndex += 1
        
        self.position = position
        
        numResources += 1
        allDetectables.updateValue(self, forKey: name!)
        scene.addChild(self)
    }
    
    static func remove(name: String) {
        if numResources > 0 {
            numResources -= 1
        }
        allDetectables.removeValue(forKey: name)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
