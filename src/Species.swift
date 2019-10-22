//
//  Species.swift
//  Natural Selection
//
//  Created by Maxwell Kleinsasser on 12/26/18.
//  Copyright © 2018 Maxwell Kleinsasser. All rights reserved.
//
//  This file contains the class object, each node contains a reference
//  to a species object. New species instances are created upon the
//  generation of a new random node or upon speciation.
//

import Foundation
import SpriteKit

// all species key-value array for global usage
var allSpecies = [Int : Species]()

public class Species : SKNode, Comparable {
    
    // static fields
    static var counter = 0
    public static var activeSpecies = 0
    
    // instance fields
    var id : String
    var idInt : Int
    var color : UIColor
    var count = 0
    var members = [String : Node]()
    var parentName : String
    var newName : String
    var fullName : String
    var age : Int = 0
    
    var rep : Node
    var parentSpecies : Species?
    var decendants = [Species]()
    var ancestors = [Species]()
    var isExtict = false
    
    // constructors
    init(rep: Node) {
        self.rep = rep
        
        id = "\(Species.counter)"
        idInt = Species.counter
        color = getRandomColor()
        count += 1
        members.updateValue(rep, forKey: rep.name!)
        parentName = "nodus"
        newName = randomWord(wordLength: Int.random(in: 3...8))
        fullName = "\(parentName) \(newName)"
        Species.activeSpecies += 1
        
        super.init()
        
        rep.gameScene?.addChild(self)
        startAgeCount()
        
        allSpecies.updateValue(self, forKey: Species.counter)
        Species.counter += 1
    }
    
    init(rep: Node, parentSpecies: Species) {
        self.rep = rep
        
        id = "\(Species.counter)"
        idInt = Species.counter
        color = UIColor.blend(color1: parentSpecies.color, color2: getRandomColor())
        count += 1
        members.updateValue(rep, forKey: rep.name!)
        parentName = parentSpecies.newName
        newName = randomWord(wordLength: Int.random(in: 3...8))
        fullName = "\(parentName) \(newName)"
        Species.activeSpecies += 1
        
        super.init()
        
        rep.gameScene?.addChild(self)
        startAgeCount()
        
        self.parentSpecies = parentSpecies
        
        allSpecies.updateValue(self, forKey: Species.counter)
        Species.counter += 1
    }
    
    override init() {
        self.rep = Node()
        self.id = ""
        self.idInt = -1
        self.color = .clear
        self.newName = ""
        self.parentName = ""
        self.fullName = ""
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func eradicate() {
        self.removeAllActions()
        isExtict = true
        allSpecies.removeValue(forKey: self.idInt)
        Species.activeSpecies -= 1
        self.removeFromParent()
    }
    
    func startAgeCount() {
        let wait = SKAction.wait(forDuration: 1.0)
        let incrementTime = SKAction.run {
            self.age += 1
        }
        self.run(SKAction.repeatForever(SKAction.sequence([
            wait,
            incrementTime
            ])))
    }
    
    public static func < (lhs: Species, rhs: Species) -> Bool {
        return lhs.idInt < rhs.idInt
    }
    
    public static func == (lhs: Species, rhs: Species) -> Bool {
        return lhs.idInt == rhs.idInt
    }
    
    // logic for constructing species bar graph in simulation
    static func getSpeciesFequencyChart() -> [SKShapeNode] {
        var chartMembers = [SKShapeNode]()
        
        for s in allSpecies.values.sorted(by: <) {
            let rect = CGRect(x: 0, y: 0, width: s.members.count * Int(Config.screenSize.width * 0.003), height: Int(Config.screenSize.height * 0.01))
            let mem = SKShapeNode(rect: rect)
            mem.name = "C\(s.id)"
            mem.strokeColor = .clear
            mem.fillColor = s.color
            mem.zPosition = 9
            chartMembers.append(mem)
        }
        
        return chartMembers
    }
    
    static var chartMembers = [SKShapeNode]()
    
    static func drawSpeciesFrequencyChart(startingPoint: CGPoint, scene: SKScene) {
        for m in Species.chartMembers {
            m.removeFromParent()
        }
        
        Species.chartMembers = Species.getSpeciesFequencyChart()
        let xpos = startingPoint.x
        var ypos = startingPoint.y
        
        for m in Species.chartMembers {
            m.position = CGPoint(x: xpos, y: ypos)
            ypos += Config.screenSize.height * 0.01
            scene.camera!.addChild(m)
        }
    }
    
    static func getSpecies(id: String) -> Species {
        for s in allSpecies.values {
            if s.id == id {
                return s
            }
        }
        return Species()
    }
    
}

// generate a random NSColor
public func getRandomColor() -> UIColor {
    //Generate between 0 to 1
    let red = CGFloat.random(in: 0...1)
    let green = CGFloat.random(in: 0...1)
    let blue = CGFloat.random(in: 0...1)
    
    return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
}
