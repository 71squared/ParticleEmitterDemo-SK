//
//  SKParticleEmitter.swift
//  ParticleEmitterDemo-SK
//
//  Created by Peter Easdown on 27/3/21.
//  Copyright © 2021 71Squared Ltd. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

class SKParticleEmitter : SKNode, BaseParticleEmitterDelegate {

    var emitter : BaseParticleEmitter?
    var texture : SKTexture?
    var particleNodeIndex : NSInteger = 1

    var particleNodes = Array<SKSpriteNode>()
    
    static let shader : SKShader = SKParticleEmitter.createShader()

    static func createShader() -> SKShader {
        let u = SKUniform(name: "u_opacityModifyRGB")
        u.floatValue = 1.0

        let result = SKShader(fileNamed:  "skParticleFragmentShader.fsh")
        result.addUniform(u)
        
        return result
    }
    
    init(withConfigFile fileName: String) throws {
        particleNodeIndex = 0
        
        super.init()

        emitter = try BaseParticleEmitter.load(withFile: fileName, delegate: self)!
        
        self.loadTexture()
        self.setupArrays()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadTexture() {
        self.texture = emitter?.textureDetails!.texture()!
    }

    func setupArrays() {
        for _ in 0 ..< emitter!.maxParticles.int {
            let particleNode = SKSpriteNode(texture: self.texture)
            particleNode.size = .zero
            particleNode.shader = SKParticleEmitter.shader
            self.particleNodes.append(particleNode)
            particleNode.isHidden = true
            particleNode.color = .init(red: 1.0, green: 0.3, blue: 0.5, alpha: 0.5)
            self.addChild(particleNode)
        }
    }
    
    func update(withDelta aDelta: PEFloat) {
        self.emitter?.update(withDelta: aDelta)
        
        var particleNode : SKSpriteNode

        for pi in 0 ..< emitter!.particleCount {
            particleNode = particleNodes[pi]
            
            let p = emitter!.particles[pi]
            particleNode.position = CGPoint(x: CGFloat(p.position.x), y: CGFloat(p.position.y))
            particleNode.size = .init(width: CGFloat(p.particleSize.float), height: CGFloat(p.particleSize.float))
            particleNode.color = p.color.asUIColor()
            particleNode.zRotation = CGFloat(GLKMathDegreesToRadians(p.rotation.float))
            particleNode.colorBlendFactor = 1.0
            particleNode.blendMode = .add
        }
    }

    func addParticle() {
        let particleNode = self.particleNodes[self.particleNodeIndex]
        particleNode.isHidden = false
        
        particleNodeIndex += 1
        assert(particleNodeIndex <= emitter!.maxParticles.int)
    }

    func removeParticle(atIndex index: Int) {
        particleNodeIndex -= 1
        assert(particleNodeIndex >= 0)

        let particleNode = self.particleNodes[self.particleNodeIndex]
        particleNode.isHidden = true
    }

}
