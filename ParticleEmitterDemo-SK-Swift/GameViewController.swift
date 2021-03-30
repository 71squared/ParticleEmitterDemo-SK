//
//  GameViewController.swift
//  ParticleEmitterDemo-SK-Swift
//
//  Created by Peter Easdown on 27/3/21.
//  Copyright © 2021 71Squared Ltd. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            view.showsFPS = true
            view.showsNodeCount = true

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            view.ignoresSiblingOrder = true

            // Load the SKScene from 'GameScene.sks'
            let scene = GameScene(size: CGSize(width: 320, height: 568))
                //SKScene(fileNamed: "GameScene")
                
            // Present the scene
            view.presentScene(scene)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
