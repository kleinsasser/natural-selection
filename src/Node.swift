//
//  Node.swift
//  Natural Selection
//
//  Created by Maxwell Kleinsasser on 12/10/18.
//  Copyright © 2018 Maxwell Kleinsasser. All rights reserved.
//
//  File contains the Node class. Most of the essential logic for the program
//  is contained in this file somewhere.

import Foundation
import SpriteKit
import GameplayKit

// global arrays storing all nodes/detectables
public var allNodes = [String : Node]()
public var allDetectables = [String : Detectable]()

extension UIColor {
    // function for blending colors for speciation
    static func blend(color1: UIColor, intensity1: CGFloat = 0.5, color2: UIColor, intensity2: CGFloat = 0.5) -> UIColor {
        let total = intensity1 + intensity2
        let l1 = intensity1/total
        let l2 = intensity2/total
        guard l1 > 0 else { return color2}
        guard l2 > 0 else { return color1}
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(red: l1*r1 + l2*r2, green: l1*g1 + l2*g2, blue: l1*b1 + l2*b2, alpha: l1*a1 + l2*a2)
    }
}

public class Node : Detectable {
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// NODE PROPERTIES ///////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Class Variables
    static let texture1 = SKTexture(imageNamed: "Node1.png")
    static let texture2 = SKTexture(imageNamed: "Node2.png")
    static let textures = [texture1, texture2]
    
    static var counter = 0 // Counter for ID assignment
    static let delay = SKAction.wait(forDuration: 1.0)
    static let fadeOut = SKAction.fadeOut(withDuration: 0.5)
    
    var reproductionRate : Double = 0 // determines rate of asexual reproduction
    var radius : CGFloat = 0 // body radius of node
    var feedRate : Float = 0 // resources depleted per second
    
    var isDead = false
    var preying = true
    var startingPos = CGPoint.zero // used as default angle in the lack of detection
    
    var resources : Float = -1 // current quantity of consumed resources
    var maxResourceCapacity : Float = 0 // maximum resource capacity
    
    var gen = 1 // the generation of the species of which the node is a member
    var offspring = 0 // counter for number of offspring of node
    var age : Int = 0 // counter for node age
    
    var detectLine = SKShapeNode() // line for detection visualization
    var gameScene : SKScene? // SKScene used for adding offspring to scene
    
    // weights of movement function
    var w1 = [[Float]]()
    var w2 = [[Float]]()
    var w3 = [[Float]]()
    var w = [[[Float]]]()
    
    // biases of movement function
    var b = [Float]()
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// PRIMARY INITIALIZER /////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    init(prodType: productionType, parentName: String, scene: SKScene) {
        if prodType == .asexual {
            
            // inherit mutated physical properties
            let parent : Node = allNodes[parentName]!
            reproductionRate = parent.reproductionRate * Double.random(in: 0.8...1.2)
            radius = parent.radius * CGFloat.random(in: 0.95...1.05)
            gen = parent.gen + 1
            feedRate = Float(radius * 0.005) * Float(Config.nodeMovementRefreshRate)
            maxResourceCapacity = Float(radius)
            gameScene = scene
            self.resources = 0.0 // resources added from parent
            
            // inherit mutated neural net parameters
            w = Node.mutateWeights(weights: parent.w)
            w1 = w[0]
            w2 = w[1]
            w3 = w[2]
            
            b = Node.mutateBiases(biases: parent.b)
            
            super.init(texture: Node.texture1, color: .black, size: CGSize(width: radius * (10/6) * 2, height: radius * 2))
            
            position = parent.position
            startingPos = position
            
            // check if speciation should occur
            if Node.compareNodes(self, (parent.species?.rep)!) || !Config.speciation {
                species = parent.species
                species?.count += 1
                name = "S\(species!.id)-N\(species!.count)"
                species?.members.updateValue(self, forKey: self.name!)
            } else {
                name = "S\(Species.counter)-N1"
                species = Species(rep: self, parentSpecies: parent.species!)
                parent.species?.decendants.append(self.species!)
                species?.ancestors = parent.species!.ancestors
                species?.ancestors.append(parent.species!)
                gen = 1
                if Config.debugSpeciation {
                    print("Speciation: ", self.position )
                }
            }
            
        } else {
            // random node generation
            reproductionRate = 10.0 * Double.random(in: 0.8...1.2)
            radius = 10 * CGFloat.random(in: 0.5...1.5)
            maxResourceCapacity = Float(radius)
            resources = maxResourceCapacity / 4
            gameScene = scene
            feedRate = Float(radius * 0.005) * Float(Config.nodeMovementRefreshRate)
            
            // assign random weights
            w1 = [
                Node.randomVector(4),
                Node.randomVector(4),
                Node.randomVector(4)
            ]
            
            w2 = [
                Node.randomVector(3),
                Node.randomVector(3),
                Node.randomVector(3)
            ]
            
            w3 = [
                Node.randomVector(3),
                Node.randomVector(3)
            ]
            
            w = [w1, w2, w3]
            
            b = Node.randomVector(8)
            
            super.init(texture: Node.texture1, color: .black, size: CGSize(width: radius * (10/6) * 2, height: radius * 2))
            
            position = getNewStartingPosition()
            startingPos = position
            name = "S\(Species.counter)-N1"
            species = Species(rep: self)
            
        }
        
        if allNodes.updateValue(self, forKey: name!) != nil {
            if Config.debugAddRemove {
                print("id copied:", self.name!)
            }
        }
        allDetectables.updateValue(self, forKey: name!)
        
        color = species?.color ?? .black
        colorBlendFactor = 1
        size = CGSize(width: radius * (10/6) * 2, height: radius * 2)
        zRotation = 0
        physicsBody = SKPhysicsBody.init(circleOfRadius: radius)
        physicsBody?.linearDamping = 0
        physicsBody?.allowsRotation = true
        physicsBody?.collisionBitMask = 1
        physicsBody?.categoryBitMask = 1
        physicsBody?.contactTestBitMask = 1
        physicsBody?.allowsRotation = false
        
        quad = Quad(self)
        
        startFlapping()
        startAgeCount()
        startMovement()
        if Config.nodesStarve {startStarvation()}
        if Config.nodesReproduceAsexual {startReproduction()}
        
        scene.addChild(self)
        
        if Config.debugAddRemove {
            print("node added", self.name!)
        }
        if Config.debugNodeInitialValues {
            print("Node: ", self.name!)
            print("color:", self.species?.color as Any)
            print("reproduction rate:", self.reproductionRate)
            print("Body radius:", self.radius)
            print("feedRate:", self.feedRate)
            print("max resource capacity:", self.maxResourceCapacity)
            print("mass:", physicsBody?.mass ?? 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// NODE INIT HELPERS //////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // generate random weight for movement function
    static func randomFloat() -> Float {
        return Float.random(in: -1...1)
    }
    
    // generate random vector of random weights with specified length
    static func randomVector(_ length: Int) -> [Float] {
        var out = [Float]()
        
        for _ in 1...length {
            out.append(randomFloat())
        }
        
        return out
    }
    
    // take a set of nn weights and return a mutated version of said weights
    static func mutateWeights(weights: [[[Float]]]) -> [[[Float]]] {
        var w = [[[Float]]]()
        
        for i in 0...weights.count - 1 {
            w.append([[Float]]())
            for j in 0...weights[i].count - 1 {
                w[i].append([Float]())
                for k in 0...weights[i][j].count - 1 {
                    w[i][j].append(weights[i][j][k] * Float.random(in: 0.8...1.2))
                }
            }
        }
        
        return w
    }
    
    static func mutateBiases(biases: [Float]) -> [Float] {
        var mutated = [Float]()
        
        for b in biases {
            mutated.append(b + Float.random(in: -1...1))
        }
        
        return mutated
    }
    
    func reproduceAsexually() {
        self.delayPreying()
        let n = Node(prodType: .asexual, parentName: self.name!, scene: self.scene!)
        n.addResources(amount: Float(radius * 0.125))
        resources -= Float(radius * 0.25)
        offspring += 1
    }
    
    // compares nodes for speciation
    public static func compareNodes(_ node1: Node,_ node2: Node) -> Bool {
        var diff = [Float]()
        
        for i in 0...node1.w.count-1 { // % difference of all movement function weights
            for j in 0...node1.w[i].count-1 {
                for k in 0...node1.w[i][j].count-1 {
                    diff.append(abs((node2.w[i][j][k] / node1.w[i][j][k]) - 1.0))
                }
            }
        }
        
        diff.append(Float(abs((node2.radius / node1.radius) - 1))) // % difference in radius
        diff.append(Float(abs((node2.reproductionRate / node1.reproductionRate) - 1))) // % diff in reproduction
        
        var totalDiff : Float = 0
        for i in diff { // add all values
            totalDiff += i
        }
        
        if (totalDiff / Float(diff.count)) > Config.speciationThreshold { // difference threshold for speciation
            return false
        } else {
            return true
        }
    }
    
    // enum for distinguishing node initialization
    public enum productionType {
        case sexual // not implemented
        case asexual
        case random
    }
    
    // no argument initializer for default nodes
    init() {
        gameScene = SKScene()
        reproductionRate = 0
        radius = 0
        feedRate = 0
        maxResourceCapacity = 0
        isDead = true
        resources = 0
        
        w1 = [
            Node.randomVector(4),
            Node.randomVector(4),
            Node.randomVector(4)
        ]
        
        w2 = [
            Node.randomVector(3),
            Node.randomVector(3),
            Node.randomVector(3)
        ]
        
        w3 = [
            Node.randomVector(3),
            Node.randomVector(3)
        ]
        
        w = [w1, w2, w3]
        
        super.init(texture: SKTexture(), color: .clear, size: CGSize())
        name = "Default"
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// NODE DEATH LOGIC //////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func addResources(amount: Float) {
        self.resources += amount
        if self.resources > self.maxResourceCapacity {
            self.resources = self.maxResourceCapacity
        }
    }
    
    static func starveNode(node: Node) {
        if node.isDead {
            return
        }
        let remove = removeNode(node: node)
        node.color = UIColor.blend(color1: node.color, color2: UIColor.gray)
        node.run(SKAction.sequence([
            delay,
            fadeOut,
            remove
            ]))
    }
    
    static func freezeNode(node: Node) {
        if node.isDead {
            return
        }
        let remove = removeNode(node: node)
        node.color = UIColor.blend(color1: node.color, color2: UIColor.white)
        node.run(SKAction.sequence([
            delay,
            fadeOut,
            remove
            ]))
    }
    
    static func burnNode(node: Node) {
        if node.isDead {
            return
        }
        let remove = removeNode(node: node)
        node.color = UIColor.blend(color1: node.color, color2: UIColor.black)
        node.run(SKAction.sequence([
            delay,
            fadeOut,
            remove
            ]))
    }
    
    static func consumeNode(node: Node, consumer: Node) {
        if node.isDead {
            return
        }
        
        consumer.addResources(amount: Float(node.radius * 0.25))
        
        let remove = removeNode(node: node)
        node.zPosition = -1
        node.run(SKAction.move(to: consumer.position, duration: 0.1))
        node.run(SKAction.sequence([
            SKAction.scale(to: 0, duration: 0.1),
            remove
            ]))
    }
    
    static func removeNode(node: Node) -> SKAction {
        if Config.debugAddRemove {
            print("kill requested on ", node.name ?? "")
        }
        
        node.isDead = true
        node.detectLine.removeFromParent()
        node.physicsBody?.categoryBitMask = 0 // disclude dead node from collisions
        node.removeAllActions()
        
        if node.species?.members.removeValue(forKey: node.name!) == nil {
            print("failed to remove dead node from species member array")
        }
        
        if (node.species?.members.count)! <= 0 {
            node.species?.eradicate()
        }
        
        return SKAction.run {
            node.removeFromParent()
            if allNodes.removeValue(forKey: node.name!) == nil {
                if Config.debugAddRemove {
                    print("allNodes removal failed:", node.name!)
                }
            } else {
                if Config.debugAddRemove {
                    print(node.name!, "successfully removed from allNodes")
                }
            }
            if allDetectables.removeValue(forKey: node.name!) == nil {
                if Config.debugAddRemove {
                    print("allDetectables removal failed", node.name!)
                }
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// NODE MOVEMENT LOGIC ////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // not used
    func getTemp() -> CGFloat {
        return self.position.x / Config.sceneWidth
    }
    
    // get angle between two points
    func getAngle(p1: CGPoint, p2: CGPoint) -> CGFloat {
        if Config.debugMovement {
            print("Calculating angle: p1", p1, "p2", p2)
        }
        if p1 == p2 {
            return 0;
        }
        let p = CGPoint(x: p2.x-p1.x, y: p2.y-p1.y)
        var angle = atan(p.y / p.x) * (180 / .pi)
        
        if (p.x / p.y) < 0 { angle = 180 + angle }
        if p.y > 0 { angle += 180 }
        
        return angle
    }
    
    // get nearest neighbor data
    func closestDetectableData() -> [CGFloat] {
        var closest : CGFloat = 200
        var nn = allDetectables["Default"]
        var detected = false
        
        for i in -1...1 {
            for j in -1...1 {
                for d in Quad.quads["\(self.quad.x + i)\(self.quad.y + j)"] ?? [Detectable]() {
                    if Config.cannibalism {
                        if d.name != "Unnamed" && d.name != self.name {
                            let dist = calcDistance(a: self.position, b: d.position)
                            if dist < closest {
                                closest = dist
                                nn = d
                                detected = true
                            }
                        }
                    } else {
                        if (d.species != self.species) && d.name != "Unnamed" {
                            let dist = calcDistance(a: self.position, b: d.position)
                            if dist < closest {
                                closest = dist
                                nn = d
                                detected = true
                            }
                        }
                    }
                }
            }
        }
        
        var size = CGFloat()
        var angle = CGFloat()
        var distance = CGFloat()
        
        if detected {
            if Config.showDetectLines {
                let path = CGMutablePath()
                path.addLines(between: [nn?.position ?? CGPoint(x: 0, y: 0), self.position])
                detectLine.removeFromParent()
                detectLine = SKShapeNode(path: path)
                detectLine.strokeColor = self.color
                self.gameScene?.addChild(detectLine)
            } else {
                detectLine.removeFromParent()
            }
            
            size = (nn?.size.height ?? 20) / 2
            angle = getAngle(p1: nn?.position ?? CGPoint(x: 0, y: 0), p2: self.position)
            distance = calcDistance(a: self.position, b: nn?.position ?? CGPoint.zero)
        } else {
            detectLine.removeFromParent()
            
            size = 0
            angle = getAngle(p1: self.position, p2: self.startingPos)
            distance = 200
        }
        
        if Config.debugMovement {
            print("NNSize:", size, "NNAngle:", angle, "Detecting:", detected)
        }
        return [size, angle, distance]
    }
    
    // gather input for movement function
    func getInput() -> [Float] {
        var input = [Float]()
        var neighborData = closestDetectableData()
        
        // nearest neighbor size relative to own size
        input.append(Float((neighborData[0] - radius) / radius))
        if input[0] > 1.0 {
            input[0] = 1.0
        } else if input[0] < -1.0 {
            input[0] = -1.0
        }
        // nearest neighbor direction
        input.append(Float(neighborData[1] / 360))
        // nearest neighbor distance
        input.append(Float(neighborData[2]) / 200)
        // current percent resource capacity filled
        if maxResourceCapacity > 0 {
            input.append(Float(self.resources / self.maxResourceCapacity))
        } else {
            input.append(1.0)
        }
        
        if Config.debugMovement {
            print("input: ", input)
        }
        return input
    }
    
    // neural net calculation
    static func feedNeuralNet(input: [Float], w: [[[Float]]], b: [Float]) -> [Float] {
        
        // hidden layer 1
        let h1 = [dotp4(x: input, y: w[0][0]) + b[0], dotp4(x: input, y: w[0][1]) + b[1], dotp4(x: input, y: w[0][2]) + b[2]]
        // hidden layer 2
        let h2 = [dotp3(x: h1, y: w[1][0]) + b[3], dotp3(x: h1, y: w[1][1]) + b[4], dotp3(x: h1, y: w[1][2]) + b[5]]
        // output layer
        let out = [dotp3(x: h2, y: w[2][0]) + b[6], dotp3(x: h2, y: w[2][1]) + b[7]]
        
        return out
    }
    
    // calculates and applies movement with assigned weights
    public func updateMovement() {
        let out = Node.feedNeuralNet(input: getInput(), w: w, b: b)
        if Config.debugMovement {
            print(self.name ?? "", out, "\n")
        }
        
        if Config.movementCostsResources {
            resources -= abs(out[1] * Float(Config.nodeMovementRefreshRate / 10) + feedRate)
        } else {
            resources -= feedRate
        }
        
        let radians = (out[0] * 360) * (.pi / 180)
        let speedMult = CGFloat(abs(out[1] * Config.universalSpeedMultiplier))
        
        let vector = CGVector(dx: CGFloat(cos(radians)) * speedMult, dy: CGFloat(sin(radians)) * speedMult)
        
        if Config.nodesMove {
            self.zRotation = CGFloat(radians - (.pi / 2))
            self.physicsBody?.isResting = true
            self.physicsBody?.applyForce(vector)
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////// NODE TIMERS ////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func startMovement() {
        let delay = SKAction.wait(forDuration: Config.nodeMovementRefreshRate)
        let move = SKAction.run {
            self.updateMovement()
        }
        run(SKAction.repeatForever(SKAction.sequence([
            delay,
            move
            ])))
    }
    
    func startReproduction() {
        let delay = SKAction.wait(forDuration: reproductionRate)
        let reproduce = SKAction.run {
            if self.resources >= Float(self.radius * 0.25) {
                self.reproduceAsexually()
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([
            delay,
            reproduce
            ])))
    }
    
    func startAgeCount() {
        let wait = SKAction.wait(forDuration: 1.0)
        let increment = SKAction.run {
            self.age += 1
        }
        
        self.run(SKAction.repeatForever(SKAction.sequence([
            wait,
            increment
            ])))
    }
    
    func startStarvation() {
        let delay = SKAction.wait(forDuration: 2.0)
        let checkStarvation = SKAction.run {
            if self.resources <= 0 {
                Node.starveNode(node: self)
            } else {
                
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([
            delay,
            checkStarvation
            ])))
    }
    
    func startFlapping() {
        let flap = SKAction.animate(with: Node.textures, timePerFrame: 0.25 / 2)
        run(SKAction.repeatForever(flap))
    }
    
    func delayPreying() {
        let wait = SKAction.wait(forDuration: 2.0)
        let preyingOff = SKAction.run {
            self.preying = false
        }
        let preyingOn = SKAction.run {
            self.preying = true
        }
        
        run(SKAction.sequence([
            preyingOff,
            wait,
            preyingOn
            ]))
    }
    
}

// HELPER METHODS

// function for calculating the distance between two points
public func calcDistance(a: CGPoint, b: CGPoint) -> CGFloat {
    let xDist = a.x - b.x
    let yDist = a.y - b.y
    return CGFloat(sqrt(xDist * xDist + yDist * yDist))
}

// function for getting a new starting position for a randomly generated node
func getNewStartingPosition() -> CGPoint {
    return CGPoint(x: CGFloat.random(in: -Config.sceneWidth/2...Config.sceneWidth/2), y: CGFloat.random(in: -Config.sceneHeight/2...Config.sceneHeight/2))
}

// optimized dot product methods for neural network
func dotp4(x: [Float], y: [Float]) -> Float {
    return (x[0] * y[0]) + (x[1] * y[1]) + (x[2] * y[2]) + (x[3] * y[3])
}

func dotp3(x: [Float], y: [Float]) -> Float {
    return (x[0] * y[0]) + (x[1] * y[1]) + (x[2] * y[2])
}

