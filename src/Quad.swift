//
//  Quad.swift
//  Natural Selection
//
//  Created by Maxwell Kleinsasser on 1/11/19.
//  Copyright © 2019 Maxwell Kleinsasser. All rights reserved.
//
//  My solution to the getting nearest neighbor data. Divides the simulation
//  into a grid of 100 pixel squares or "quads", then 4 times a second every
//  detectable on the map is stored in a hash-table-esque array
//  (because I didn't actually know what a hash table was when I made this)
//  of the quad they're in.
//
//  This way when a node needs to compute it's nearest neighbor it only has
//  to calculate the distance between itself and the other detectables in its
//  surrounding quads as opposed to every detactable in the simulation.
//
//  This method allows for the simulation to run at 60fps with >1000 nodes in the
//  simulation as opposed to around 300 with every node checking every detectable.

import Foundation
import SpriteKit

public class Quad : CustomStringConvertible {
    
    static let quadSize : CGFloat = 100
    
    static let dividersX = Int(Config.sceneWidth / Quad.quadSize)
    static let dividersY = Int(Config.sceneHeight / Quad.quadSize)
    
    // array storing all detectables
    static var quads = [String : [Detectable]]()
    
    static func updateQuadValues() {
        
        var tempQuads = [String : [Detectable]]()
        for i in 0...dividersX-1 {
            for j in 0...dividersY-1 {
                tempQuads.updateValue([Detectable](), forKey: "\(i)\(j)")
            }
        }
        
        for d in allDetectables.values {
            let posX = d.position.x + (Config.sceneWidth / 2)
            let posY = d.position.y + (Config.sceneHeight / 2)
            
            let quadX = Int((CGFloat(dividersX) * posX) / Config.sceneWidth)
            let quadY = Int((CGFloat(dividersY) * posY) / Config.sceneHeight)
            
            d.quad.x = quadX
            d.quad.y = quadY
            
            if quadX >= 0 && quadX <= dividersX-1 && quadY >= 0 && quadY <= dividersY-1 {
                tempQuads["\(quadX)\(quadY)"]?.append(d)
            }
            
        }
        Quad.quads = tempQuads
    }
    
    static func startUpdatingQuads(scene: SKScene) {
        let delay = SKAction.wait(forDuration: Config.nodeMovementRefreshRate)
        let update = SKAction.run {
            Quad.updateQuadValues()
        }
        scene.run(SKAction.repeatForever(SKAction.sequence([
            delay,
            update
            ])))
    }
    
    static var quadLines = [SKShapeNode]()
    
    static func drawQuadLines(scene: SKScene) {
        Quad.quadLines = [SKShapeNode]()
        
        let xInterval = Int(Config.sceneWidth) / dividersX
        for i in 0...dividersX {
            let line = SKShapeNode(rect: CGRect(x: (Config.sceneFrame.minX) + CGFloat(i * xInterval), y: Config.sceneFrame.minY, width: 0, height: Config.sceneHeight))
            line.strokeColor = .black
            line.zPosition = 2
            scene.addChild(line)
            Quad.quadLines.append(line)
        }
        
        let yInterval = Int(Config.sceneHeight) / dividersY
        for i in 0...dividersY {
            let line = SKShapeNode(rect: CGRect(x: (Config.sceneFrame.minX), y: (Config.sceneFrame.minY) + CGFloat(i * yInterval), width: Config.sceneWidth, height: 0))
            line.strokeColor = .black
            line.zPosition = 2
            scene.addChild(line)
            Quad.quadLines.append(line)
        }
    }
    
    static func removeQuadLines() {
        for line in Quad.quadLines {
            line.removeFromParent()
        }
    }
    
    var x : Int
    var y : Int
    
    init() {
        self.x = 0
        self.y = 0
    }
    
    public var description: String {
        return "Quad - x: \(self.x), y: \(self.y)"
    }
    
    init(_ d: Detectable) {
        let posX = d.position.x + (Config.sceneWidth / 2)
        let posY = d.position.y + (Config.sceneHeight / 2)
        
        let quadX = Int((CGFloat(Quad.dividersX) * posX) / Config.sceneWidth)
        let quadY = Int((CGFloat(Quad.dividersY) * posY) / Config.sceneHeight)
        
        self.x = quadX
        self.y = quadY
        
        if quadX >= 0 && quadX <= Quad.dividersX-1 && quadY >= 0 && quadY <= Quad.dividersY-1 {
            Quad.quads["\(quadX)\(quadY)"]?.append(d)
        }
    }
}
