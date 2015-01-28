//
//  ParticleEmitter.h
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

// Particle type
enum kParticleTypes {
	kParticleTypeGravity,
	kParticleTypeRadial
};

// Structure that holds the location and size for each point sprite
typedef struct {
	GLfloat     x;
	GLfloat     y;
    GLfloat     s;
    GLfloat     t;
	GLKVector4 color;
} PointSprite;

typedef struct {
    GLKVector2  vertex;
    GLKVector2  texture;
    GLKVector4  color;
    GLfloat     particleSize;
    GLfloat     rotationRad;
    GLKVector2  positionMultiplier;
} TexturedColoredVertex;

typedef struct {
    TexturedColoredVertex bl;
    TexturedColoredVertex br;
    TexturedColoredVertex tl;
    TexturedColoredVertex tr;
} ParticleQuad;

// Structure used to hold particle specific information
typedef struct {
	GLKVector2  position;
	GLKVector2  direction;
    GLKVector2  startPos;
	GLKVector4  color;
	GLKVector4  deltaColor;
    GLfloat     rotation;
    GLfloat     rotationDelta;
    GLfloat     radialAcceleration;
    GLfloat     tangentialAcceleration;
	GLfloat     radius;
	GLfloat     radiusDelta;
	GLfloat     angle;
	GLfloat     degreesPerSecond;
	GLfloat     particleSize;
	GLfloat     particleSizeDelta;
	GLfloat     timeToLive;
} Particle;

// The particleEmitter allows you to define parameters that are used when generating particles.
// These particles are OpenGL particle sprites that based on the parameters provided each have
// their own characteristics such as speed, lifespan, start and end colors etc.  Using these
// particle emitters allows you to create organic looking effects such as smoke, fire and 
// explosions.
//
@interface BaseParticleEmitter : NSObject {
    
	/////////////////// Flags to enable/disable functionality
    BOOL            updateParticlePositionAndRotation;
    
	/////////////////// Particle iVars
    NSString        *_textureFileName;
    NSString        *_textureFileData;
    NSData          *_tiffData;
    UIImage         *_image;
    CGImageRef      _cgImage;

	/////////////////// Particle iVars
    int             emitterType;
	GLKVector2      sourcePosition, sourcePositionVariance;
	GLfloat         angle, angleVariance;
	GLfloat         speed, speedVariance;
    GLfloat         radialAcceleration, tangentialAcceleration;
    GLfloat         radialAccelVariance, tangentialAccelVariance;
	GLKVector2      gravity;
	GLfloat         particleLifespan, particleLifespanVariance;
	GLKVector4      startColor, startColorVariance;
	GLKVector4      finishColor, finishColorVariance;
	GLfloat         startParticleSize, startParticleSizeVariance;
	GLfloat         finishParticleSize, finishParticleSizeVariance;
	GLuint          maxParticles;
	GLint           particleCount;
	GLfloat         emissionRate;
	GLfloat         emitCounter;
	GLfloat         elapsedTime;
	GLfloat         duration;
    GLfloat         rotationStart, rotationStartVariance;
    GLfloat         rotationEnd, rotationEndVariance;
    
    GLuint          vertexArrayName;

	int             blendFuncSource, blendFuncDestination;
    
    BOOL            _opacityModifyRGB;
    BOOL            _premultiplied;
    BOOL            _hasAlpha;

	//////////////////// Particle ivars only used when a maxRadius value is provided.  These values are used for
	//////////////////// the special purpose of creating the spinning portal emitter
	GLfloat         maxRadius;						// Max radius at which particles are drawn when rotating
	GLfloat         maxRadiusVariance;				// Variance of the maxRadius
	GLfloat         radiusSpeed;					// The speed at which a particle moves from maxRadius to minRadius
	GLfloat         minRadius;						// Radius from source below which a particle dies
	GLfloat         rotatePerSecond;				// Numeber of degress to rotate a particle around the source pos per second
	GLfloat         rotatePerSecondVariance;		// Variance in degrees for rotatePerSecond

	//////////////////// Particle Emitter iVars
	BOOL            active;
    GLint           vertexIndex;         // Stores the index of the vertices being used for each particle
	
	///////////////////// Render
	Particle        *particles;		// Array of particles that hold the particle emitters particle details
	ParticleQuad    *quads, *quads2;        // Array holding quad information for each particle;
}

@property (nonatomic, assign)   GLKVector2      sourcePosition;
@property (nonatomic, assign)   GLint           particleCount;
@property (nonatomic, assign)   BOOL            active;
@property (nonatomic, assign)   GLfloat         duration;


// Initialises a particle emitter using configuration read from a file
- (id)initParticleEmitterWithFile:(NSString*)aFileName;

// Updates all particles in the particle emitter
- (void)updateWithDelta:(GLfloat)aDelta;

- (void)updateParticleAtIndex:(unsigned long)index withDelta:(float)delta;

// Stops the particle emitter
- (void)stopParticleEmitter;

// Resets the particle system
- (void)reset;

// Adds a particle from the particle pool to the emitter
- (BOOL)addParticle;

// Initialises a particle ready for use
- (void)initParticle:(Particle*)particle;

// Load the particle texture
- (void)loadTexture;

// Setup particle arrays
- (void)setupArrays;

// Removes a particle at the specified index
- (void) removeParticleAtIndex:(int)index;

@end
