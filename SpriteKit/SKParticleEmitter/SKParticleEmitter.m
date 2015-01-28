//
//  SKParticleEmitter.m
//  ParticleEmitterDemo-SK
//
//  Created by Tom Bradley on 10/02/2014.
//  Copyright (c) 2014 71Squared Ltd. All rights reserved.
//

#import "SKParticleEmitter.h"

@interface SKParticleEmitter() {
    SKUniform *_u;
}
@end

@implementation SKParticleEmitter

- (void)loadTexture {
    _texture = [SKTexture textureWithCGImage:_cgImage];
}

- (void)setupArrays {
    [super setupArrays];
    
    _u = [SKUniform uniformWithName:@"u_opacityModifyRGB"];
    
    NSString *shaderFile = [[NSBundle mainBundle] pathForResource:@"skParticleFragmentShader.fsh" ofType:nil];
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderFile encoding:NSASCIIStringEncoding error:nil];
    _shader = [[SKShader alloc] initWithSource:shaderString];
    
    [_u setFloatValue:1];
    [_shader addUniform:_u];
    
    _emitter = [SKNode new];
    _particleNodes = [[NSMutableArray alloc] initWithCapacity:maxParticles];
    
    for (int i=0; i<maxParticles; i++) {
        SKSpriteNode *particleNode = [SKSpriteNode spriteNodeWithTexture:_texture];
        [particleNode setSize:CGSizeMake(0, 0)];
        particleNode.shader = _shader;
        [_particleNodes addObject:particleNode];
        [particleNode setHidden:YES];
        particleNode.color = [SKColor colorWithRed:1.0 green:0.3 blue:0.5 alpha:0.5];
        [_emitter addChild:particleNode];
    }
}

- (void)updateWithDelta:(GLfloat)aDelta {
    [super updateWithDelta:aDelta];
    
    SKSpriteNode *particleNode;
    
    for (int i=0; i<particleCount; i++) {
        particleNode = _particleNodes[i];
        Particle p = particles[i];
        [particleNode setPosition:CGPointMake(p.position.x,
                                              p.position.y)];
        [particleNode setSize:CGSizeMake(p.particleSize, p.particleSize)];
        particleNode.color = [SKColor colorWithRed:p.color.r green:p.color.g blue:p.color.b alpha:p.color.a];
        particleNode.zRotation = GLKMathDegreesToRadians(p.rotation);
        particleNode.colorBlendFactor = 1.0;
        particleNode.blendMode = SKBlendModeAdd;
    }
}

- (BOOL)addParticle {
    BOOL success = [super addParticle];
    
    if (success) {
        SKSpriteNode *particleNode = [_particleNodes objectAtIndex:particleNodeIndex];
        [particleNode setHidden:NO];
        
        particleNodeIndex++;
        assert(particleNodeIndex <= maxParticles);
    }
    
    return success;
}

- (void)removeParticleAtIndex:(int)index {
    [super removeParticleAtIndex:index];
    
    particleNodeIndex--;
    assert(particleNodeIndex >= 0);
    
    SKSpriteNode *particleNode = [_particleNodes objectAtIndex:particleNodeIndex];
    [particleNode setHidden:YES];
}

@end
