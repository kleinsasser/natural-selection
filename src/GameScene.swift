//
//  GameScene.swift
//  Natural Selection
//
//  Created by Maxwell Kleinsasser on 12/8/18.
//  Copyright © 2018 Maxwell Kleinsasser. All rights reserved.
//
//  File contains logic for running the simulation, including a lot of
//  necessary SpriteKit physics jargon as well as important simulation logic
//  such as collision handling (nodes eating) and user interfaces (which you
//  wont see on the github post).

import SpriteKit

let pause = SKTexture(imageNamed: "Pause.png")
let play = SKTexture(imageNamed: "Play.png")
let zoom = SKTexture(imageNamed: "Plus.png")
let zoomOut = SKTexture(imageNamed: "Minus.png")
let show = SKTexture(imageNamed: "View.png")
let settings = SKTexture(imageNamed: "Settings.png")

var hudFrame = CGRect()

var nodesPaused = false

public class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var activeNode = Node()
    
    var cameraNode = SKCameraNode()
    
    var speciesDataLabel = DataBox()
    var simDataLabel = DataBox()
    
    var togglers = [LabeledButtonToggler]()
    var incrementers = [LabeledButtonIncrementer]()
    
    let settingsButton = Button(textures: [settings], action: SKAction())
    
    let pauseButton = Button(textures: [pause, play], action: SKAction.run {
        for node in allNodes.values {
            node.isPaused.toggle()
            node.physicsBody?.isResting.toggle()
            
            if nodesPaused {
                node.species?.isPaused = true
            } else {
                node.species?.isPaused = false
            }
        }
    })
    var showingSettings = false
    let fader = SKSpriteNode(texture: SKTexture(imageNamed: "DataBox.png"))
    
    var showingHelp = false
    
    let speciesNameLabel = SKLabelNode()
    let simulationDataLabel = SKLabelNode()
    var nodeDataLabels = [SKLabelNode]()
    
    public override func didMove(to view: SKView) {
        
        Config.screenSize = self.size
        
        print("name:", UIDevice.current.name)
        print("model:", UIDevice.current.model)
        if (UIDevice.current.model.contains("iPad")) {
            print("iPad detected")
            size = CGSize(width: size.width, height: size.height * 0.8)
        }
        
        Config.screenFrame = self.frame
        
        let bgRect = SKShapeNode(rect: Config.sceneFrame)
        bgRect.strokeColor = .black
        bgRect.lineWidth = 5
        bgRect.fillColor = .clear
        bgRect.zPosition = -1
        addChild(bgRect)
        
        self.backgroundColor = UIColor.init(red: 0.83, green: 0.96, blue: 1.0, alpha: 1.0)
        self.backgroundColor = .white
        self.physicsWorld.gravity = CGVector.zero
        self.physicsWorld.contactDelegate = self
        
        let spacer = Config.buttonSize.width * (7/6)
        
        if UIDevice.current.model.contains("iPad") {
            hudFrame = CGRect(x: 0 - (frame.width * 0.45), y: 0 - (frame.height * 0.445), width: frame.width * 0.9, height: frame.height * 0.89)
        } else {
            hudFrame = CGRect(x: 0 - (frame.width * 0.375), y: 0 - (frame.height * 0.445), width: frame.width * 0.75, height: frame.height * 0.89)
        }
        
        /*
        let frameRect = SKShapeNode(rect: hudFrame)
        frameRect.fillColor = .clear
        frameRect.strokeColor = .blue
        frameRect.zPosition = 9
        // cameraNode.addChild(frameRect)
        */
 
        camera = cameraNode
        addChild(cameraNode)
        
        self.name = "World"
        
        speciesNameLabel.text = "(no node selected)"
        speciesNameLabel.fontName = "Arial Bold"
        speciesNameLabel.fontColor = .black
        speciesNameLabel.fontSize = Config.screenSize.height * 0.025
        speciesNameLabel.horizontalAlignmentMode = .right
        speciesNameLabel.verticalAlignmentMode = .top
        speciesNameLabel.position = CGPoint(x: hudFrame.maxX, y: hudFrame.maxY)
        speciesNameLabel.zPosition = 10
        cameraNode.addChild(speciesNameLabel)
        
        for i in 0...13 {
            
            switch i {
            case 0:
                nodeDataLabels.append(SKLabelNode(text: "Species Data"))
                break
            case 1:
                nodeDataLabels.append(SKLabelNode(text: "Species Age: "))
                break
            case 2:
                nodeDataLabels.append(SKLabelNode(text: "Members: "))
                break
            case 3:
                nodeDataLabels.append(SKLabelNode(text: "Parent Species: "))
                break
            case 4:
                nodeDataLabels.append(SKLabelNode(text: "Ancestors: "))
                break
            case 5:
                nodeDataLabels.append(SKLabelNode(text: "Decendants: "))
                break
            case 6:
                nodeDataLabels.append(SKLabelNode(text: "Individual Data"))
                break
            case 7:
                nodeDataLabels.append(SKLabelNode(text: "Age: "))
                break
            case 8:
                nodeDataLabels.append(SKLabelNode(text: "Resource Capacity: "))
                break
            case 9:
                nodeDataLabels.append(SKLabelNode(text: "% Filled: "))
                break
            case 10:
                nodeDataLabels.append(SKLabelNode(text: "Size: "))
                break
            case 11:
                nodeDataLabels.append(SKLabelNode(text: "ID: "))
                break
            case 12:
                nodeDataLabels.append(SKLabelNode(text: "Gen. in Species: "))
                break
            case 13:
                nodeDataLabels.append(SKLabelNode(text: "Offspring: "))
                break
            default:
                break
            }
            
            nodeDataLabels[i].fontName = "Arial Bold"
            nodeDataLabels[i].fontColor = .black
            nodeDataLabels[i].fontSize = Config.screenSize.height * 0.013
            nodeDataLabels[i].horizontalAlignmentMode = .right
            nodeDataLabels[i].verticalAlignmentMode = .top
            nodeDataLabels[i].zPosition = 10
            
            if nodeDataLabels[i].text == "Species Data" || nodeDataLabels[i].text == "Individual Data" {
                nodeDataLabels[i].fontSize = Config.screenSize.height * 0.018
            }
            
            if i == 0 {
                nodeDataLabels[i].position = CGPoint(x: hudFrame.maxX, y: hudFrame.maxY - (speciesNameLabel.frame.height * 1.2))
            } else if nodeDataLabels[i].text == "Individual Data" {
                nodeDataLabels[i].position = CGPoint(x: hudFrame.maxX, y: nodeDataLabels[i-1].position.y - (nodeDataLabels[i-1].frame.height * 1.4))
            } else {
                nodeDataLabels[i].position = CGPoint(x: hudFrame.maxX, y: nodeDataLabels[i-1].position.y - (nodeDataLabels[i-1].frame.height * 1.1))
            }
            
            cameraNode.addChild(nodeDataLabels[i])
            
        }
        
        let updateNodeDataLabels = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run {
                for i in 0...self.nodeDataLabels.count-1 {
                    if self.activeNode.maxResourceCapacity != 0 {
                        self.nodeDataLabels[i].isHidden = false
                        switch i {
                        case 0:
                            break
                        case 1: // species age
                            self.nodeDataLabels[i].text = "Species Age: \(self.activeNode.species!.age / 60)M \(self.activeNode.species!.age % 60)S"
                            break
                        case 2: // species members
                            self.nodeDataLabels[i].text = "Members: \(self.activeNode.species!.members.count)"
                            break
                        case 3: // parent species
                            self.nodeDataLabels[i].text = "Parent Species: \(self.activeNode.species!.parentSpecies?.fullName ?? "None")"
                            break
                        case 4: // ancestors
                            self.nodeDataLabels[i].text = "Ancestors: \(self.activeNode.species!.ancestors.count)"
                            break
                        case 5: // decendants
                            self.nodeDataLabels[i].text = "Decendants: \(self.activeNode.species!.decendants.count)"
                            break
                        case 6:
                            break
                        case 7: // node age
                            self.nodeDataLabels[i].text = "Node Age: \(self.activeNode.age / 60)M \(self.activeNode.age % 60)S"
                            break
                        case 8: // max resource capacity
                            self.nodeDataLabels[i].text = "Resource Capacity: \(self.truncateFloat(CGFloat(self.activeNode.maxResourceCapacity), to: 4))"
                            break
                        case 9: // percent resources filled
                            self.nodeDataLabels[i].text = "% Capacity Full: \(self.truncateFloat(CGFloat((self.activeNode.resources / self.activeNode.maxResourceCapacity) * 100), to: 4))"
                            break
                        case 10: // radius
                            self.nodeDataLabels[i].text = "Node Size: \(self.truncateFloat(self.activeNode.radius, to: 4))"
                            break
                        case 11: // id
                            self.nodeDataLabels[i].text = "Node ID: \(self.activeNode.name!)"
                            break
                        case 12: // generation
                            self.nodeDataLabels[i].text = "Generation: \(self.activeNode.gen)"
                            break
                        case 13: // offspring
                            self.nodeDataLabels[i].text = "Offspring: \(self.activeNode.offspring)"
                            break
                        default:
                            break
                        }
                    } else {
                        self.nodeDataLabels[i].isHidden = true
                    }
                }
            }
            ]))
        run(updateNodeDataLabels)
        
        simulationDataLabel.numberOfLines = 3
        simulationDataLabel.text = "\n\n\n"
        simulationDataLabel.fontName = "Arial Bold"
        simulationDataLabel.fontColor = .black
        simulationDataLabel.fontSize = Config.screenSize.height * 0.015
        simulationDataLabel.horizontalAlignmentMode = .left
        simulationDataLabel.verticalAlignmentMode = .top
        simulationDataLabel.position = CGPoint(x: hudFrame.minX, y: hudFrame.maxY)
        simulationDataLabel.zPosition = 10
        cameraNode.addChild(simulationDataLabel)
        
        // additional setup
        Quad.updateQuadValues()
        if Config.debugPartitioning {Quad.drawQuadLines(scene: self)}
        Quad.startUpdatingQuads(scene: self)
        
        allDetectables.updateValue(Detectable(texture: SKTexture(), color: UIColor.clear, size: CGSize()), forKey: "Default")
        
        let drawSpeciesChart = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run {
                Species.drawSpeciesFrequencyChart(startingPoint: CGPoint(x: hudFrame.minX, y: hudFrame.minY + Config.buttonSize.height / 2), scene: self)
            }
            ]))
        run(drawSpeciesChart)
        
        let fillResources = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run({
                if Config.resourcesPerSecond > 0 {
                    for _ in 1...Int(Config.resourcesPerSecond) {
                        if numResources < Config.maxResources && !nodesPaused {
                            _ = Resource(scene: self)
                        }
                    }
                }
            })
            ]))
        run(fillResources)
        
        let cleanDoomedNodes = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 10.0),
            SKAction.run {
                for n in allNodes {
                    let node = n.value
                    if calcDistance(a: CGPoint.zero, b: node.position) > Config.sceneWidth {
                        Node.starveNode(node: node)
                    }
                }
            }
            ]))
        run(cleanDoomedNodes)
        
        let zoomInButton = Button(textures: [zoom], action: SKAction.run({
            if self.cameraNode.xScale > 0.5 {
                self.cameraNode.xScale -= 0.5
                self.cameraNode.yScale -= 0.5
            }
        }))
        zoomInButton.position = CGPoint(x: hudFrame.midX + (spacer / 2), y: hudFrame.minY)
        cameraNode.addChild(zoomInButton)
        
        let zoomOutButton = Button(textures: [zoomOut], action: SKAction.run {
            if self.cameraNode.xScale < 6.0 {
                self.cameraNode.xScale += 0.5
                self.cameraNode.yScale += 0.5
            }
        })
        zoomOutButton.position = CGPoint(x: hudFrame.midX - (spacer / 2), y: hudFrame.minY)
        cameraNode.addChild(zoomOutButton)
        
        pauseButton.name = "pause"
        pauseButton.position = CGPoint(x: zoomInButton.position.x + spacer, y: hudFrame.minY)
        cameraNode.addChild(pauseButton)
        
        fader.size = CGSize(width: 30000, height: 30000)
        fader.alpha = 0.75
        fader.isHidden = true
        fader.zPosition = 9.1
        addChild(fader)
        
        settingsButton.name = "settings"
        settingsButton.alpha = 0.5
        settingsButton.position = CGPoint(x: hudFrame.maxX - (Config.buttonSize.width/2), y: hudFrame.minY)
        cameraNode.addChild(settingsButton)
        
        togglers.append(LabeledButtonToggler(value: Config.greaterEnergyConsumes, label: "Greater Energy Wins", index: 2))
        togglers[0].position = CGPoint(x: hudFrame.maxX - (togglers[0].size.width/2), y: hudFrame.minY + (spacer * 3))
        togglers[0].toggleHidden()
        togglers[0].helpBox.title.text = "Greater Energy Wins"
        togglers[0].helpBox.text.text = """
        If enabled, the node moving with greater kinetic energy (mv^2) will consume the other upon contact.
        
        This configuration incentivizes both larger and faster moving nodes.
        """
        cameraNode.addChild(togglers[0])
        cameraNode.addChild(togglers[0].helpBox.background)
        
        togglers.append(LabeledButtonToggler(value: Config.cannibalism, label: "Cannibalism", index: 1))
        togglers[1].helpBox.title.text = "Cannibalism"
        togglers[1].helpBox.text.text = """
        Determines whether nodes of the same species can detect and consume each other.
        
        Enabling will likely lead to population self-decimation.
        """
        
        togglers.append(LabeledButtonToggler(value: Config.smallerConsumes, label: "Inferior Nodes Win", index: 0))
        togglers[2].helpBox.title.text = "Inferior Nodes Win"
        togglers[2].helpBox.text.text = """
        If enabled, smaller nodes will consume larger nodes, incentivizing small species.
        
        If enabled with 'Greater Energy Wins' also enabled, nodes moving with lesser kinetic energy will consume.
        """
        
        togglers.append(LabeledButtonToggler(value: Config.showDetectLines, label: "Show Detection", index: 3))
        togglers[3].helpBox.title.text = "Show Detection"
        togglers[3].helpBox.text.text = """
        The lines you see protruding from each node every second show what object the node is 'seeing'.
        
        This is a visual configuration.
        """
        
        togglers.append(LabeledButtonToggler(value: Config.speciation, label: "Speciation", index: 5))
        togglers[4].helpBox.title.text = "Speciation"
        togglers[4].helpBox.text.text = """
        If a node produced asexually is sufficiently different from its parent, it will be given a slightly different color and declared a new species. Turn this configuration off to disable this feature.
        
        Use if you want to experiment with the evolution of a single species without interruption. If speciation is re-enabled after a species has sufficiently evolved, a species explosion will likely occur.
        """
        
        togglers.append(LabeledButtonToggler(value: Config.movementCostsResources, label: "Movement Costs Resources", index: 4))
        togglers[5].helpBox.title.text = "Movement Costs Resources"
        togglers[5].helpBox.text.text = """
        Nodes by default must expend resources for moving proportional to the speed of the action.
        
        Disable this configuration to make all movements free from resource expulsion.
        
        This configuration disabled paired with 'Greater Energy Wins' enabled incentivazes very fast-moving species.
        """
        
        togglers.append(LabeledButtonToggler(value: Config.tracking, label: "Track Selected Node", index: 6))
        togglers[6].helpBox.title.text = "Track Selected Node"
        togglers[6].helpBox.text.text = """
        A visual configuration determining whether the selected node is followed by the simulation camera.
        
        May not be a useful configuration to disable depending on whether I fixed it by release time.
        """
        
        for i in 1...togglers.count-1 {
            togglers[i].position = CGPoint(x: togglers[0].position.x, y: togglers[0].position.y + ((togglers[0].size.height * 1.2) * CGFloat(i)))
            cameraNode.addChild(togglers[i])
            cameraNode.addChild(togglers[i].helpBox.background)
            togglers[i].toggleHidden()
        }
        
        incrementers.append(LabeledButtonIncrementer(value: Double(Config.minActiveSpecies), label: "Min Active Species", increment: 10.0, index: 0, min: 0, max: 100))
        incrementers[0].helpBox.title.text = "Minimum Active Species"
        incrementers[0].helpBox.text.text = """
        The simulation keeps track of how many different species are currently alive.
        
        This configuration determines how many unique species should be sustained in the simulation.
        
        Keep in mind that with a sufficiently dominant species controlling the simulation, new species essentially become additional resources to feed on.
        """
        
        incrementers.append(LabeledButtonIncrementer(value: Config.resourcesPerSecond, label: "Resources Per Second", increment: 10.0, index: 1, min: 0.0, max: 100.0))
        incrementers[1].helpBox.title.text = "Resources Per Second"
        incrementers[1].helpBox.text.text = """
        Determines how many resources are spawned into the simulation per second.
        
        Can be used to control the population of a dominant node species.
        
        Slowly cut off resources to encourage the evolution of more efficient resource consumers.
        """
        
        incrementers.append(LabeledButtonIncrementer(value: Double(Config.universalSpeedMultiplier/100), label: "Node Speed Multiplier", increment: 1, index: 2, min: 1, max: 10))
        incrementers[2].helpBox.title.text = "Universal Speed Multiplier"
        incrementers[2].helpBox.text.text = """
        Increases or decreases the movement speed of all nodes.
        
        Can be helpful in speeding up evolution of large, slow-moving species or slowing down extremely fast-moving species.
        """
        
        incrementers.append(LabeledButtonIncrementer(value: 4, label: "Speciation Threshold", increment: 2, index: 5, min: 2, max: 20))
        incrementers[3].helpBox.title.text = "Speciation Threshold"
        incrementers[3].helpBox.text.text = """
        Determines how different a newborn node must be from its parent species to be declared a new species.
        
        The greater the threshold, the more different it must be for speciation.
        """
        
        for i in 0...incrementers.count-1 {
            if i == 0 {
                let ref = togglers[togglers.count - 1].position
                incrementers[i].position = CGPoint(x: ref.x, y: ref.y + spacer)
            } else {
                let ref = incrementers[i-1].position
                incrementers[i].position = CGPoint(x: ref.x, y: ref.y + (incrementers[i-1].size.height * 1.2))
            }
            cameraNode.addChild(incrementers[i])
            cameraNode.addChild(incrementers[i].helpBox.background)
            incrementers[i].toggleHidden()
        }
    }
    
    func calcKineticEnergy(velocity: CGVector, mass: CGFloat) -> CGFloat {
        let speed = sqrt(pow(abs(velocity.dx),2) + pow(abs(velocity.dy),2))
        
        return mass * speed
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.node?.name?.first == "R" && contact.bodyB.node?.name?.first == "S" {
            let node = contact.bodyB.node as! Node
            if !node.isDead {
                node.addResources(amount: 1)
                Resource.remove(name: (contact.bodyA.node?.name)!)
                contact.bodyA.node?.removeFromParent()
            }
        }
        
        if contact.bodyA.node?.name?.first == "S" && contact.bodyB.node?.name?.first == "R" {
            let node = contact.bodyA.node as! Node
            if !node.isDead {
                node.addResources(amount: 1)
                Resource.remove(name: (contact.bodyB.node?.name)!)
                contact.bodyB.node?.removeFromParent()
            }
        }

        if Config.nodesAreConsumed && contact.bodyA.node?.name?.first == "S" && contact.bodyB.node?.name?.first == "S" {
            let node1 = contact.bodyA.node as! Node
            let node2 = contact.bodyB.node as! Node
            if Config.debugCollisions {
                print("Collision: ", node1.name ?? "", node2.name ?? "")
            }
            
            if !node1.isDead && !node2.isDead {
                if Config.greaterEnergyConsumes {
                    let node1Energy = calcKineticEnergy(velocity: (node1.physicsBody?.velocity)!, mass: (node1.physicsBody?.mass)!)
                    let node2Energy = calcKineticEnergy(velocity: (node2.physicsBody?.velocity)!, mass: (node2.physicsBody?.mass)!)
                    
                    if node1.species?.id != node2.species?.id || Config.cannibalism {
                        if node1Energy > node2Energy {
                            if Config.smallerConsumes && node2.preying {
                                Node.consumeNode(node: node1, consumer: node2)
                            } else if node1.preying {
                                Node.consumeNode(node: node2, consumer: node1)
                            }
                        } else if node1Energy < node2Energy {
                            if Config.smallerConsumes && node1.preying {
                                Node.consumeNode(node: node2, consumer: node1)
                            } else if node2.preying {
                                Node.consumeNode(node: node1, consumer: node2)
                            }
                        }
                    }
                    return
                }
                
                if node1.species?.id != node2.species?.id || Config.cannibalism {
                    if node1.radius > node2.radius {
                        if Config.smallerConsumes && node2.preying {
                            Node.consumeNode(node: node1, consumer: node2)
                        } else if node1.preying {
                            Node.consumeNode(node: node2, consumer: node1)
                        }
                    } else if node2.radius > node1.radius {
                        if Config.smallerConsumes && node1.preying {
                            Node.consumeNode(node: node2, consumer: node1)
                        } else if node2.preying {
                            Node.consumeNode(node: node1, consumer: node2)
                        }
                    }
                }
            }
        }
    }
    
    var selectionCircle = SKShapeNode(circleOfRadius: 20)
    
    var nodeFound = false
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        selectionCircle.zPosition = 9
        
        for touch in touches {
            
            nodeFound = false
            
            for node in nodes(at: touch.location(in: self)) {
                
                if showingHelp {
                    for t in togglers {
                        t.helpBox.background.isHidden = true
                    }
                    
                    for i in incrementers {
                        i.helpBox.background.isHidden = true
                    }
                    showingHelp = false
                    return
                }
                
                if node is HelpBox {
                    let help = node as! HelpBox
                    help.background.isHidden = false
                    for label in help.background.children {
                        label.isHidden = false
                    }
                    showingHelp = true
                    
                    return
                }
                
                if node is LabeledButtonToggler {
                    let toggler = node as! LabeledButtonToggler
                    toggler.toggleValue()
                    nodeFound = true
                    return
                }
                
                if node is LabeledButtonIncrementer {
                    let incrementer = node as! LabeledButtonIncrementer
                    incrementer.incrementValue()
                    nodeFound = true
                    return
                }
                
                if node is LabeledButtonAction {
                    let action = node as! LabeledButtonAction
                    action.runAction()
                    nodeFound = true
                    return
                }
                
                if node is Button {
                    let action = node as! Button
                    
                    if action.name == "pause" {
                        action.press()
                        nodesPaused.toggle()
                    }

                    else if action.name == "settings" {
                        
                        for t in self.togglers {
                            t.toggleHidden()
                        }
                        
                        for i in self.incrementers {
                            i.toggleHidden()
                        }
                        
                        if showingSettings {
                            settingsButton.alpha = 0.5
                            fader.isHidden = true
                        } else {
                            settingsButton.alpha = 1.0
                            fader.isHidden = false
                        }
                        showingSettings.toggle()
                    } else {
                        action.press()
                    }
                    nodeFound = true
                    return
                }
                
                if node is Node {
                    activeNode = node as! Node
                    
                    selectionCircle.removeFromParent()
                    selectionCircle = SKShapeNode(circleOfRadius: activeNode.radius + 5)
                    selectionCircle.strokeColor = .red
                    selectionCircle.fillColor = .clear
                    selectionCircle.zPosition = 10
                    activeNode.addChild(selectionCircle)
                    nodeFound = true
                    
                    break
                }
                
            }
            if !nodeFound {
                activeNode = Node()
                selectionCircle.removeFromParent()
                let location = touch.location(in: cameraNode)
                
                if location.y > (size.height * 0.1) {
                    cameraNode.run(SKAction.repeatForever(SKAction.moveBy(x: 0, y: 160, duration: 0.2)))
                } else if location.y < -(size.height * 0.17) {
                    cameraNode.run(SKAction.repeatForever(SKAction.moveBy(x: 0, y: -160, duration: 0.2)))
                } else if location.x > 0 {
                    cameraNode.run(SKAction.repeatForever(SKAction.moveBy(x: 160, y: 0, duration: 0.2)))
                } else if location.x < 0 {
                    cameraNode.run(SKAction.repeatForever(SKAction.moveBy(x: -160, y: 0, duration: 0.2)))
                }
                
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        cameraNode.removeAllActions()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !Config.tracking {
            activeNode.position = (touches.first?.location(in: self))!
        }
    }
    
    var p = false
    
    public func truncateFloat(_ num : CGFloat, to: Int) -> String {
        let str = "\(num)"
        
        var x = to
        if to >= str.count {
            x = str.count
        }
        
        return String(str.dropLast(str.count - x))
    }
    
    func updateLabels() {
        if showingSettings {
            speciesNameLabel.text = "Configurations"
            speciesNameLabel.fontColor = .black
        } else if activeNode.species == nil {
            speciesNameLabel.text = "(no species selected)"
            speciesNameLabel.fontColor = .lightGray
        } else {
            speciesNameLabel.text = activeNode.species?.fullName
            speciesNameLabel.fontColor = .black
        }
        
        simulationDataLabel.text = """
        Nodes: \(allNodes.count)
        Species: \(allSpecies.count)
        Resources: \(numResources)
        FPS: \(fps)
        """
     }
    
    var lastUpdateTime: TimeInterval = 0
    var fps: Int = 0
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if Species.activeSpecies < Config.minActiveSpecies && !nodesPaused {
            _ = Node(prodType: .random, parentName: "", scene: self)
        }
        
        if !activeNode.isDead && Config.tracking {
            camera?.position = activeNode.position
        }
        
        let deltaTime = currentTime - lastUpdateTime
        let currentFPS = 1 / deltaTime
        fps = Int(currentFPS) + 1 
        
        lastUpdateTime = currentTime
        
        updateLabels()
    }
    
}
