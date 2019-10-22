//
//  Detectable.swift
//  Natural Selection
//
//  Created by Maxwell Kleinsasser on 1/13/19.
//  Copyright © 2019 Maxwell Kleinsasser. All rights reserved.
//
//  Contains the Detectable class which is inherited from by the Node
//  and Resource classes primarily for Node detection purposes.

import Foundation
import SpriteKit

public class Detectable : SKSpriteNode {
    
    var quad = Quad()
    var species : Species?
    
    init(texture: SKTexture, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.name = "Unnamed"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
