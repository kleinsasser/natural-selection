//
//  Config.swift
//  Natural Selection
//
//  Created by Maxwell Kleinsasser on 1/7/19.
//  Copyright © 2019 Maxwell Kleinsasser. All rights reserved.
//
//  Contains simulation configurations which determine some of the rules
//  of the simulation.

import Foundation
import SpriteKit

public class Config {
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// NON-USER OPTIONS ////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////
    
    public static var debugMovement = false
    public static var debugAddRemove = false
    public static var debugNodeInitialValues = false
    public static var debugPartitioning = false
    public static var debugCollisions = false
    public static var debugSpeciation = false
    
    public static var screenSize = CGSize()
    public static var screenFrame = CGRect()
    
    public static let sceneSize = CGSize(width: sceneWidth, height: sceneHeight)
    public static let sceneFrame = CGRect(origin: CGPoint(x: -Config.sceneWidth / 2, y: -Config.sceneHeight / 2), size: sceneSize)
    
    public static let buttonSize = CGSize(width: 50, height: 50)
    
    public static let maxNodes = 1000 // unimplemented
    
    public static let nodesStarve = true
    public static let nodesMove = true
    public static let nodesReproduceAsexual = true
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// USER OPTIONS //////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////
    
    // simulation initialization values
    public static var sceneWidth : CGFloat = 3000
    public static var sceneHeight : CGFloat = 6000
    
    public static var startingResources = 400
    
    // simulation dynamic values
    public static var maxResources = 1700
    public static var resourcesPerSecond = 20.0
    public static var resourceReplusion = 0.0
    public static var resourceValue = 1.0
    public static var minActiveSpecies = 40
    public static var tracking = true
    
    public static var showDetectLines = true
    public static var nodeMovementRefreshRate = 0.25
    public static var universalSpeedMultiplier : Float = 400
    public static var movementCostsResources = true
    
    public static var smallerConsumes = false
    public static var cannibalism = false
    public static var greaterEnergyConsumes = false
    public static var speciation = true
    public static var speciationThreshold : Float = 0.04
    
    public static var nodesAreConsumed = true
    
    static func handleToggle(index: Int) {
        switch index {
        case 0:
            smallerConsumes.toggle()
            break
        case 1:
            cannibalism.toggle()
            break
        case 2:
            greaterEnergyConsumes.toggle()
            break
        case 3:
            showDetectLines.toggle()
            break
        case 4:
            movementCostsResources.toggle()
            break
        case 5:
            speciation.toggle()
            break
        case 6:
            tracking.toggle()
        default:
            print("invalid toggle index")
        }
    }
    
    static func handleIncrement(index: Int, value: Double) {
        switch index {
        case 0:
            minActiveSpecies = Int(value)
            break
        case 1:
            resourcesPerSecond = value
            break
        case 2:
            universalSpeedMultiplier = Float(value * 100)
        case 3:
            nodeMovementRefreshRate = value
        case 4:
            maxResources = Int(value)
        case 5:
            speciationThreshold = Float(value) / 100
        default:
            print("invalid increment index")
        }
    }
    
}
