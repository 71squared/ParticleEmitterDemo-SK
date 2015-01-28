//
//  ParticleEmitter.m
//  ParticleEmitterDemo
//
// Copyright (c) 2010 71Squared
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// The design and code for the ParticleEmitter were heavely influenced by the design and code
// used in Cocos2D for their particle system.

#import "BaseParticleEmitter.h"
#import "TBXML.h"
#import "TBXMLParticleAdditions.h"
#import "TBXML+Compression.h"

#pragma mark -
#pragma mark Public implementation

@implementation BaseParticleEmitter

@synthesize sourcePosition;
@synthesize active;
@synthesize particleCount;
@synthesize duration;

- (void)dealloc {
    
    // Release the memory we are using for our vertex and particle arrays etc
    // If vertices or particles exist then free them
    if (quads)
        free(quads);
    if (quads2)
        free(quads2);
    if (particles)
        free(particles);
}

- (id)initParticleEmitterWithFile:(NSString*)aFileName {
    self = [super init];
    if (self != nil) {
        
        updateParticlePositionAndRotation = YES;
        
        NSError *error;
        
        // Create a TBXML instance that we can use to parse the config file
        TBXML *particleXML = [[TBXML alloc] initWithXMLFile:aFileName error:&error];
        
        if (error)
            return nil;
        
        // Parse the config file
        [self parseParticleConfig:particleXML];
        [self setupArrays];
        [self reset];
    }
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta {
    
    // If the emitter is active and the emission rate is greater than zero then emit particles
    if (active && emissionRate) {
        GLfloat rate = 1.0f/emissionRate;
        
        if (particleCount < maxParticles)
            emitCounter += aDelta;
        
        while (particleCount < maxParticles && emitCounter > rate) {
            [self addParticle];
            emitCounter -= rate;
        }
        
        elapsedTime += aDelta;
        
        if (duration != -1 && duration < elapsedTime)
            [self stopParticleEmitter];
    }
	
    // Reset the particle index before updating the particles in this emitter
    int index = 0;
    
    // Loop through all the particles updating their location and color
    while (index < particleCount) {
        
        // Get the particle for the current particle index
        Particle *currentParticle = &particles[index];
        
        // Reduce the life span of the particle
        currentParticle->timeToLive -= aDelta;
        
        // If the current particle is alive then update it
        if (currentParticle->timeToLive > 0) {
            
            [self updateParticleAtIndex:index withDelta:aDelta];
            
            // Update the particle and vertex counters
            index++;
        } else {
            
            // As the particle is not alive anymore replace it with the last active particle
            // in the array and reduce the count of particles by one.  This causes all active particles
            // to be packed together at the start of the array so that a particle which has run out of
            // life will only drop into this clause once
            [self removeParticleAtIndex:index];
        }
    }
}

- (void)updateParticleAtIndex:(unsigned long)index withDelta:(float)delta {
    
    // Get the particle for the current particle index
    Particle *particle = &particles[index];
	
    // If maxRadius is greater than 0 then the particles are going to spin otherwise they are effected by speed and gravity
    if (emitterType == kParticleTypeRadial) {
        
        // FIX 2
        // Update the angle of the particle from the sourcePosition and the radius.  This is only done of the particles are rotating
        particle->angle += particle->degreesPerSecond * delta;
        particle->radius -= particle->radiusDelta * delta;
        
        GLKVector2 tmp;
        tmp.x = sourcePosition.x - cosf(particle->angle) * particle->radius;
        tmp.y = sourcePosition.y - sinf(particle->angle) * particle->radius;
        particle->position = tmp;
        
        if (particle->radius < minRadius)
            particle->timeToLive = 0;
        
    } else {
        GLKVector2 tmp, radial, tangential;
        
        radial = GLKVector2Zero;
        
        // By default this emitters particles are moved relative to the emitter node position
        GLKVector2 positionDifference = GLKVector2Subtract(particle->startPos, GLKVector2Zero);
        particle->position = GLKVector2Subtract(particle->position, positionDifference);
        
        if (particle->position.x || particle->position.y)
            radial = GLKVector2Normalize(particle->position);
        
        tangential = radial;
        radial = GLKVector2MultiplyScalar(radial, particle->radialAcceleration);
        
        GLfloat newy = tangential.x;
        tangential.x = -tangential.y;
        tangential.y = newy;
        tangential = GLKVector2MultiplyScalar(tangential, particle->tangentialAcceleration);
        
        tmp = GLKVector2Add( GLKVector2Add(radial, tangential), gravity);
        tmp = GLKVector2MultiplyScalar(tmp, delta);
        particle->direction = GLKVector2Add(particle->direction, tmp);
        tmp = GLKVector2MultiplyScalar(particle->direction, delta);
        particle->position = GLKVector2Add(particle->position, tmp);
        
        // Now apply the difference calculated early causing the particles to be relative in position to the emitter position
        particle->position = GLKVector2Add(particle->position, positionDifference);
    }
    
    // Update the particles color
    particle->color.r += (particle->deltaColor.r * delta);
    particle->color.g += (particle->deltaColor.g * delta);
    particle->color.b += (particle->deltaColor.b * delta);
    particle->color.a += (particle->deltaColor.a * delta);
    
    GLKVector4 c;
    
    if (_opacityModifyRGB) {
        c = (GLKVector4){particle->color.r * particle->color.a,
            particle->color.g * particle->color.a,
            particle->color.b * particle->color.a,
            particle->color.a};
    } else {
        c = particle->color;
    }
    
    // Update the particle size
    particle->particleSize += particle->particleSizeDelta * delta;
    particle->particleSize = MAX(0, particle->particleSize);
    
    // Update the rotation of the particle
    particle->rotation += particle->rotationDelta * delta;
}

- (void) removeParticleAtIndex:(int)index {
    if (index != particleCount - 1) {
        
        particles[index] = particles[particleCount - 1];
    }
    
    particleCount--;
}

- (void)stopParticleEmitter {
    active = NO;
    elapsedTime = 0;
    emitCounter = 0;
}

- (void)reset
{
    active = YES;
    elapsedTime = 0;
    for (int i = 0; i < particleCount; i++) {
        Particle *p = &particles[i];
        p->timeToLive = 0;
    }
    emitCounter = 0;
    emissionRate = maxParticles / particleLifespan;
}

- (BOOL)addParticle {
    
    // If we have already reached the maximum number of particles then do nothing
    if (particleCount == maxParticles)
        return NO;
    
    // Take the next particle out of the particle pool we have created and initialize it
    Particle *particle = &particles[particleCount];
    [self initParticle:particle];
    
    // Increment the particle count
    particleCount++;
    
    // Return YES to show that a particle has been created
    return YES;
}

- (void)initParticle:(Particle*)particle {
    
    // Init the position of the particle.  This is based on the source position of the particle emitter
    // plus a configured variance.  The RANDOM_MINUS_1_TO_1 macro allows the number to be both positive
    // and negative
    particle->position.x = sourcePosition.x + sourcePositionVariance.x * RANDOM_MINUS_1_TO_1();
    particle->position.y = sourcePosition.y + sourcePositionVariance.y * RANDOM_MINUS_1_TO_1();
    particle->startPos.x = sourcePosition.x;
    particle->startPos.y = sourcePosition.y;
    
    // Init the direction of the particle.  The newAngle is calculated using the angle passed in and the
    // angle variance.
    GLfloat newAngle = GLKMathDegreesToRadians(angle + angleVariance * RANDOM_MINUS_1_TO_1());
    
    // Create a new GLKVector2 using the newAngle
    GLKVector2 vector = GLKVector2Make(cosf(newAngle), sinf(newAngle));
    
    // Calculate the vectorSpeed using the speed and speedVariance which has been passed in
    GLfloat vectorSpeed = speed + speedVariance * RANDOM_MINUS_1_TO_1();
    
    // The particles direction vector is calculated by taking the vector calculated above and
    // multiplying that by the speed
    particle->direction = GLKVector2MultiplyScalar(vector, vectorSpeed);
    
    // Calculate the particles life span using the life span and variance passed in
    particle->timeToLive = MAX(0, particleLifespan + particleLifespanVariance * RANDOM_MINUS_1_TO_1());
    
    // Set the default diameter of the particle from the source position
    particle->radius = maxRadius + maxRadiusVariance * RANDOM_MINUS_1_TO_1();
    particle->radiusDelta = maxRadius / particle->timeToLive;
    particle->angle = GLKMathDegreesToRadians(angle + angleVariance * RANDOM_MINUS_1_TO_1());
    particle->degreesPerSecond = GLKMathDegreesToRadians(rotatePerSecond + rotatePerSecondVariance * RANDOM_MINUS_1_TO_1());
    
    particle->radialAcceleration = radialAcceleration + radialAccelVariance * RANDOM_MINUS_1_TO_1();
    particle->tangentialAcceleration = tangentialAcceleration + tangentialAccelVariance * RANDOM_MINUS_1_TO_1();
    
    // Calculate the particle size using the start and finish particle sizes
    GLfloat particleStartSize = startParticleSize + startParticleSizeVariance * RANDOM_MINUS_1_TO_1();
    GLfloat particleFinishSize = finishParticleSize + finishParticleSizeVariance * RANDOM_MINUS_1_TO_1();
    particle->particleSizeDelta = ((particleFinishSize - particleStartSize) / particle->timeToLive);
    particle->particleSize = MAX(0, particleStartSize);
    
    // Calculate the color the particle should have when it starts its life.  All the elements
    // of the start color passed in along with the variance are used to calculate the star color
    GLKVector4 start = {0, 0, 0, 0};
    start.r = startColor.r + startColorVariance.r * RANDOM_MINUS_1_TO_1();
    start.g = startColor.g + startColorVariance.g * RANDOM_MINUS_1_TO_1();
    start.b = startColor.b + startColorVariance.b * RANDOM_MINUS_1_TO_1();
    start.a = startColor.a + startColorVariance.a * RANDOM_MINUS_1_TO_1();
    
    // Calculate the color the particle should be when its life is over.  This is done the same
    // way as the start color above
    GLKVector4 end = {0, 0, 0, 0};
    end.r = finishColor.r + finishColorVariance.r * RANDOM_MINUS_1_TO_1();
    end.g = finishColor.g + finishColorVariance.g * RANDOM_MINUS_1_TO_1();
    end.b = finishColor.b + finishColorVariance.b * RANDOM_MINUS_1_TO_1();
    end.a = finishColor.a + finishColorVariance.a * RANDOM_MINUS_1_TO_1();
    
    // Calculate the delta which is to be applied to the particles color during each cycle of its
    // life.  The delta calculation uses the life span of the particle to make sure that the
    // particles color will transition from the start to end color during its life time.  As the game
    // loop is using a fixed delta value we can calculate the delta color once saving cycles in the
    // update method
    
    particle->color = start;
    particle->deltaColor.r = ((end.r - start.r) / particle->timeToLive);
    particle->deltaColor.g = ((end.g - start.g) / particle->timeToLive);
    particle->deltaColor.b = ((end.b - start.b) / particle->timeToLive);
    particle->deltaColor.a = ((end.a - start.a) / particle->timeToLive);
    
    // Calculate the rotation
    GLfloat startA = rotationStart + rotationStartVariance * RANDOM_MINUS_1_TO_1();
    GLfloat endA = rotationEnd + rotationEndVariance * RANDOM_MINUS_1_TO_1();
    particle->rotation = startA;
    particle->rotationDelta = (endA - startA) / particle->timeToLive;
    
}

- (void)parseParticleConfig:(TBXML*)aConfig {
    
    TBXMLElement *rootXMLElement = aConfig.rootXMLElement;
    
    // Make sure we have a root element or we cant process this file
    NSAssert(rootXMLElement, @"ERROR - ParticleEmitter: Could not find root element in particle config file.");
    
    
    // Load all of the values from the XML file into the particle emitter.  The functions below are using the
    // TBXMLAdditions category.  This adds convenience methods to TBXML to help cut down on the code in this method.
    emitterType                 = TBXML_INT     (rootXMLElement, @"emitterType");
    sourcePosition              = TBXML_VEC2    (rootXMLElement, @"sourcePosition");
    sourcePositionVariance      = TBXML_VEC2    (rootXMLElement, @"sourcePositionVariance");
    speed                       = TBXML_FLOAT   (rootXMLElement, @"speed");
    speedVariance               = TBXML_FLOAT   (rootXMLElement, @"speedVariance");
    particleLifespan            = TBXML_FLOAT   (rootXMLElement, @"particleLifeSpan");
    particleLifespanVariance    = TBXML_FLOAT   (rootXMLElement, @"particleLifespanVariance");
    angle                       = TBXML_FLOAT   (rootXMLElement, @"angle");
    angleVariance               = TBXML_FLOAT   (rootXMLElement, @"angleVariance");
    gravity                     = TBXML_VEC2    (rootXMLElement, @"gravity");
    radialAcceleration          = TBXML_FLOAT   (rootXMLElement, @"radialAcceleration");
    tangentialAcceleration      = TBXML_FLOAT   (rootXMLElement, @"tangentialAcceleration");
    tangentialAccelVariance     = TBXML_FLOAT   (rootXMLElement, @"tangentialAccelVariance");
    startColor                  = TBXML_VEC4    (rootXMLElement, @"startColor");
    startColorVariance          = TBXML_VEC4    (rootXMLElement, @"startColorVariance");
    finishColor                 = TBXML_VEC4    (rootXMLElement, @"finishColor");
    finishColorVariance         = TBXML_VEC4    (rootXMLElement, @"finishColorVariance");
    maxParticles                = TBXML_FLOAT   (rootXMLElement, @"maxParticles");
    startParticleSize           = TBXML_FLOAT   (rootXMLElement, @"startParticleSize");
    startParticleSizeVariance   = TBXML_FLOAT   (rootXMLElement, @"startParticleSizeVariance");
    finishParticleSize          = TBXML_FLOAT   (rootXMLElement, @"finishParticleSize");
    finishParticleSizeVariance  = TBXML_FLOAT   (rootXMLElement, @"finishParticleSizeVariance");
    duration                    = TBXML_FLOAT   (rootXMLElement, @"duration");
    blendFuncSource             = TBXML_INT     (rootXMLElement, @"blendFuncSource");
    blendFuncDestination        = TBXML_INT     (rootXMLElement, @"blendFuncDestination");
    
    // These paramters are used when you want to have the particles spinning around the source location
    maxRadius                   = TBXML_FLOAT   (rootXMLElement, @"maxRadius");
    maxRadiusVariance           = TBXML_FLOAT   (rootXMLElement, @"maxRadiusVariance");
    minRadius                   = TBXML_FLOAT   (rootXMLElement, @"minRadius");
    rotatePerSecond             = TBXML_FLOAT   (rootXMLElement, @"rotatePerSecond");
    rotatePerSecondVariance     = TBXML_FLOAT   (rootXMLElement, @"rotatePerSecondVariance");
    rotationStart               = TBXML_FLOAT   (rootXMLElement, @"rotationStart");
    rotationStartVariance       = TBXML_FLOAT   (rootXMLElement, @"rotationStartVariance");
    rotationEnd                 = TBXML_FLOAT   (rootXMLElement, @"rotationEnd");
    rotationEndVariance         = TBXML_FLOAT   (rootXMLElement, @"rotationEndVariance");
    
    // Calculate the emission rate
    emissionRate                = maxParticles / particleLifespan;
    emitCounter                 = 0;
    
    
    // First thing to grab is the texture that is to be used for the point sprite
    TBXMLElement *element = TBXML_CHILD(rootXMLElement, @"texture");
    if (element) {
        _textureFileName = TBXML_ATTRIB_STRING(element, @"name");
        _textureFileData = TBXML_ATTRIB_STRING(element, @"data");
        
        NSError *error;
        
        if (_textureFileName && !_textureFileData.length) {
            // Get path to resource
            NSString *path = [[NSBundle mainBundle] pathForResource:_textureFileName ofType:nil];
            
            // If no path is passed back then something is wrong
            NSAssert1(path, @"Unable to find texture file: %@", path);
            
            // Create a new texture which is going to be used as the texture for the point sprites. As there is
            // no texture data in the file, this is done using an external image file
            _tiffData = [[NSData alloc] initWithContentsOfFile:path options:NSDataReadingUncached error:&error];
            
            // Throw assersion error if loading texture failed
            NSAssert(!error, @"Unable to load texture");
        }
        
        // If texture data is present in the file then create the texture image from that data rather than an external file
        else if (_textureFileData.length) {
            // Decode compressed tiff data
            _tiffData = [[[NSData alloc] initWithBase64EncodedString:_textureFileData] gzipInflate];
        }
        
        
        // Create a UIImage from the tiff data to extract colorspace and alpha info
        UIImage *image = [UIImage imageWithData:_tiffData];
        _cgImage = [image CGImage];
        CGImageAlphaInfo info = CGImageGetAlphaInfo(image.CGImage);
        CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
		
        // Detect if the image contains alpha data
        _hasAlpha = ((info == kCGImageAlphaPremultipliedLast) ||
                     (info == kCGImageAlphaPremultipliedFirst) ||
                     (info == kCGImageAlphaLast) ||
                     (info == kCGImageAlphaFirst) ? YES : NO);
        
        // Detect if alpha data is premultiplied
        _premultiplied = colorSpace && _hasAlpha;
        
        // Is opacity modification required
        _opacityModifyRGB = NO;
        if (blendFuncSource == GL_ONE && blendFuncDestination == GL_ONE_MINUS_SRC_ALPHA) {
            if (_premultiplied)
                _opacityModifyRGB = YES;
            else {
                blendFuncSource = GL_SRC_ALPHA;
                blendFuncDestination = GL_ONE_MINUS_SRC_ALPHA;
            }
        }
    }
    
    [self loadTexture];
}

- (void)loadTexture {
    
}

- (void)setupArrays {
    
    // Allocate the memory necessary for the particle emitter arrays
    particles = malloc( sizeof(Particle) * maxParticles);
	
    NSAssert(particles, @"ERROR - ParticleEmitter: Could not allocate particle arrays.");
    
    // By default the particle emitter is active when created
    active = YES;
    
    // Set the particle count to zero
    particleCount = 0;
    
    // Reset the elapsed time
    elapsedTime = 0;
}

@end

