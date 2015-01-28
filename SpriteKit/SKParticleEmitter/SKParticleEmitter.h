//
//  SKParticleEmitter.h
//  ParticleEmitterDemo-SK
//
//  Created by Tom Bradley on 10/02/2014.
//  Copyright (c) 2014 71Squared Ltd. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BaseParticleEmitter.h"

@interface SKParticleEmitter : BaseParticleEmitter {
    
    SKTexture       *_texture;
    SKShader        *_shader;
    NSInteger       particleNodeIndex;

}

@property (strong, nonatomic) NSMutableArray        *particleNodes;
@property (strong, nonatomic) SKNode                *emitter;

@end
