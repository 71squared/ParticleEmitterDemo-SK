//
//  GameScene.m
//  ParticleEmitterDemo-SK
//
//  Created by Tom Bradley on 11/07/2014.
//  Copyright (c) 2014 71Squared Ltd. All rights reserved.
//

#import "GameScene.h"
#import "SKParticleEmitter.h"

@interface GameScene()
@property (nonatomic, strong) SKParticleEmitter     *particleEmitter;
@property (nonatomic, strong) NSMutableArray        *particleEmitters;
@property (strong, nonatomic) NSEnumerator          *particleEnumerator;
@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    self.backgroundColor = [SKColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	
    // Create a list of emitter configs to load
    NSArray *configs = @[
                         @"Comet.pex",
                         @"Winner Stars.pex",
                         @"Foam.pex",
                         @"Blue Flame.pex",
                         @"Atomic Bubble.pex",
                         @"Crazy Blue.pex",
                         @"Plasma Glow.pex",
                         @"Meks Blood Spill.pex",
                         @"Into The Blue.pex",
                         @"JasonChoi_Flash.pex",
                         @"Real Popcorn.pex",
                         @"The Sun.pex",
                         @"Touch Up.pex",
                         @"Trippy.pex",
                         @"Electrons.pex",
                         @"Blue Galaxy.pex",
                         @"huo1.pex",
                         @"JasonChoi_rising up.pex",
                         @"JasonChoi_Swirl01.pex",
                         @"Shooting Fireball.pex",
                         @"wu1.pex"
                         ];
    
    
    // Create a new array
    _particleEmitters = [NSMutableArray new];
    
    // Cycle through all emitters configs loading them
    for (NSString *config in configs) {
        SKParticleEmitter *particleEmitter = [[SKParticleEmitter alloc] initParticleEmitterWithFile:config];
        
        // Center the particle system
        particleEmitter.emitter.position = CGPointZero;
        
        [_particleEmitters addObject:particleEmitter];
    }
    
    // Set the current emitter to the first in the list
    [self showNextEmitter];
    
}

- (void)showNextEmitter
{
    if (_particleEmitter)
        [_particleEmitter.emitter removeFromParent];
    
    // If no enumerator exists or we've reached the last object in the enumerator, create a new enumerator
    if (!_particleEnumerator || _particleEmitter == [_particleEmitters lastObject])
        _particleEnumerator = [_particleEmitters objectEnumerator];
    
    // Get the next particle system from the enumerator and reset it
	_particleEmitter = [_particleEnumerator nextObject];
	[_particleEmitter reset];
	[_particleEmitter setSourcePosition:GLKVector2Make(self.size.width / 2, self.size.height / 2)];
	[self addChild:_particleEmitter.emitter];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self showNextEmitter];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [_particleEmitter updateWithDelta:0.016];
}

@end
