//
//  GameScene.swift
//  ClockVisualization
//
//  Created by Artturi Jalli on 22.1.2021.
//

import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        var clock = Clock(scene: self)
        clock.start()
    }
}
