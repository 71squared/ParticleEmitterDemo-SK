//
//  BaseParticleEmitter.swift
//  ParticleEmitterDemo-SK
//
//  Created by Peter Easdown on 27/3/21.
//  Copyright © 2021 71Squared Ltd. All rights reserved.
//
// This Swift class is heavily based on the original ObjectiveC classes
// available within the repository at:
//
// https://github.com/71squared/ParticleEmitterDemo-SK
//
import Foundation
import CoreGraphics
import SpriteKit

// Particle type
enum ParticleTypes : Int {
    case particleTypeGravity
    case particleTypeRadial
}

// Structure that holds the location and size for each point sprite
struct PointSprite {
    var x     : GLfloat
    var y     : GLfloat
    var s     : GLfloat
    var t     : GLfloat
    var color : GLKVector4
}

struct TexturedColoredVertex {
    var vertex              : GLKVector2
    var texture             : GLKVector2
    var color               : GLKVector4
    var particleSize        : GLfloat
    var rotationRad         : GLfloat
    var positionMultiplier  : GLKVector2
}

struct ParticleQuad {
    var bl : TexturedColoredVertex
    var br : TexturedColoredVertex
    var tl : TexturedColoredVertex
    var tr : TexturedColoredVertex
}

// Structure used to hold particle specific information
struct Particle {
    var position                : GLKVector2
    var direction               : GLKVector2
    var startPos                : GLKVector2
    var color                   : GLKVector4
    var deltaColor              : GLKVector4
    var rotation                : GLfloat
    var rotationDelta           : GLfloat
    var radialAcceleration      : GLfloat
    var tangentialAcceleration  : GLfloat
    var radius                  : GLfloat
    var radiusDelta             : GLfloat
    var angle                   : GLfloat
    var degreesPerSecond        : GLfloat
    var particleSize            : GLfloat
    var particleSizeDelta       : GLfloat
    var timeToLive              : GLfloat
}

// The particleEmitter allows you to define parameters that are used when generating particles.
// These particles are SpriteKit particle sprites that based on the parameters provided each have
// their own characteristics such as speed, lifespan, start and end colors etc.  Using these
// particle emitters allows you to create organic looking effects such as smoke, fire and
// explosions.
//
class BaseParticleEmitter {
    
    /// Flags to enable/disable functionality
    private var updateParticlePositionAndRotation : Bool
    
    /// Particle vars
    private var textureFileName : String = ""
    private var textureFileData : String = ""
    private var tiffData : Data?
    private var image : UIImage?
    private var cgImage : CGImage?
    private var emitterType : ParticleTypes = .particleTypeGravity
    private var sourcePositionVariance : GLKVector2 = .init()
    private var angle : GLfloat = 0.0
    private var angleVariance : GLfloat = 0.0
    private var speed : GLfloat = 0.0
    private var speedVariance : GLfloat = 0.0
    private var radialAcceleration : GLfloat = 0.0
    private var tangentialAcceleration : GLfloat = 0.0
    private var radialAccelVariance : GLfloat = 0.0
    private var tangentialAccelVariance : GLfloat = 0.0
    private var gravity : GLKVector2 = .init()
    private var particleLifespan : GLfloat = 0.0
    private var particleLifespanVariance : GLfloat = 0.0
    private var startColor : GLKVector4 = GLKVector4()
    private var startColorVariance : GLKVector4 = GLKVector4()
    private var finishColor : GLKVector4 = .init()
    private var finishColorVariance : GLKVector4 = .init()
    private var startParticleSize : GLfloat = 0.0
    private var startParticleSizeVariance : GLfloat = 0.0
    private var finishParticleSize : GLfloat = 0.0
    private var finishParticleSizeVariance : GLfloat = 0.0
    private var maxParticles : GLuint = 0
    private var emissionRate : GLfloat = 0.0
    private var emitCounter : GLfloat = 0.0
    private var elapsedTime : GLfloat = 0.0
    private var rotationStart : GLfloat = 0.0
    private var rotationStartVariance : GLfloat = 0.0
    private var rotationEnd : GLfloat = 0.0
    private var rotationEndVariance : GLfloat = 0.0
    private var vertexArrayName : GLuint = 0
    private var blendFuncSource : Int = 0
    private var blendFuncDestination : Int = 0
    private var opacityModifyRGB : Bool = false
    private var premultiplied : Bool = false
    private var hasAlpha : Bool = true
    
    /// Particle vars only used when a maxRadius value is provided.  These values are used for
    /// the special purpose of creating the spinning portal emitter
    private var maxRadius : GLfloat  = 0.0               /// Max radius at which particles are drawn when rotating
    private var maxRadiusVariance : GLfloat = 0.0        /// Variance of the maxRadius
    private var radiusSpeed : GLfloat = 0.0              /// The speed at which a particle moves from maxRadius to minRadius
    private var minRadius : GLfloat = 0.0                /// Radius from source below which a particle dies
    private var rotatePerSecond : GLfloat = 0.0          /// Number of degress to rotate a particle around the source pos per second
    private var rotatePerSecondVariance : GLfloat = 0.0  /// Variance in degrees for rotatePerSecond
    
    /// Particle Emitter Vars
    private var active : Bool = false
    private var vertexIndex : GLint = 0              /// Stores the index of the vertices being used for each particle
    
    /// Render
    private var particles = Array<Particle>()         /// Array of particles that hold the particle emitters particle details
    private var quads = Array<ParticleQuad>()
        private var quads2 = Array<ParticleQuad>() /// Array holding quad information for each particle : ParticleQuad
    
    
    var sourcePosition : GLKVector2 = .init()
    var particleCount : Int = 0
    var duration : GLfloat = 0.0
    
    deinit {
        // Release the memory we are using for our vertex and particle arrays etc
        // If vertices or particles exist then free them
        self.quads.removeAll()
        self.quads2.removeAll()
        self.particles.removeAll()
    }
    
    init(withFile: String) throws {
        updateParticlePositionAndRotation = true
        
        if let fileURL = Bundle.main.url(forResource: withFile, withExtension: nil) {
            let data = try Data(contentsOf: fileURL)
            
            if let particleXML = XmlReader.dictionaryForXMLData(data: data) {
                self.parse(particleConfig: particleXML)
                self.setupArrays()
                self.reset()
            }
        }
    }
    
    func update(withDelta aDelta: GLfloat) {
        
        // If the emitter is active and the emission rate is greater than zero then emit particles
        if active && (emissionRate > 0) {
            let rate : GLfloat = 1.0 / emissionRate
            
            if (particleCount < maxParticles) {
                emitCounter += aDelta
            }
            
            while (particleCount < maxParticles && emitCounter > rate) {
                _ = self.addParticle()
                
                emitCounter -= rate
            }
            
            elapsedTime += aDelta
            
            if (duration != -1 && duration < elapsedTime) {
                self.stopParticleEmitter()
            }
        }
        
        // Reset the particle index before updating the particles in this emitter
        var index : Int = 0;
        
        // Loop through all the particles updating their location and color
        while index < particleCount {
            
            // Get the particle for the current particle index
            var currentParticle : Particle = particles[index]
            
            // Reduce the life span of the particle
            currentParticle.timeToLive -= aDelta
            
            // If the current particle is alive then update it
            if currentParticle.timeToLive > 0 {
                
                self.updateParticle(atIndex : index, withDelta : aDelta)
                
                // Update the particle and vertex counters
                index += 1
            } else {
                
                // As the particle is not alive anymore replace it with the last active particle
                // in the array and reduce the count of particles by one.  This causes all active particles
                // to be packed together at the start of the array so that a particle which has run out of
                // life will only drop into this clause once
                self.removeParticle(atIndex : index)
            }
        }
    }
    
    func updateParticle(atIndex index : Int, withDelta delta : GLfloat) {
        
        // Get the particle for the current particle index
        var particle : Particle = particles[index]
        
        // If maxRadius is greater than 0 then the particles are going to spin otherwise they are effected by speed and gravity
        if emitterType == .particleTypeRadial {
            
            // FIX 2
            // Update the angle of the particle from the sourcePosition and the radius.  This is only done of the particles are rotating
            particle.angle += particle.degreesPerSecond * delta
            particle.radius -= particle.radiusDelta * delta
            
            particle.position = GLKVector2Make(sourcePosition.x - cosf(particle.angle) * particle.radius, sourcePosition.y - sinf(particle.angle) * particle.radius)
            
            if (particle.radius < minRadius) {
                particle.timeToLive = 0
            }
            
        } else {
            var tmp, radial, tangential : GLKVector2
            
            let vec2Zero = GLKVector2Make(0.0, 0.0)
            
            radial = vec2Zero
            
            
            // By default this emitters particles are moved relative to the emitter node position
            let positionDifference = GLKVector2Subtract(particle.startPos, vec2Zero)
            particle.position = GLKVector2Subtract(particle.position, positionDifference)
            
            if particle.position.x > 0.0 || particle.position.y > 0.0 {
                radial = GLKVector2Normalize(particle.position)
            }
            
            tangential = radial
            radial = GLKVector2MultiplyScalar(radial, particle.radialAcceleration)
            
            let newy = tangential.x
            tangential.x = -tangential.y
            tangential.y = newy
            tangential = GLKVector2MultiplyScalar(tangential, particle.tangentialAcceleration)
            
            tmp = GLKVector2Add( GLKVector2Add(radial, tangential), gravity)
            tmp = GLKVector2MultiplyScalar(tmp, delta)
            particle.direction = GLKVector2Add(particle.direction, tmp)
            tmp = GLKVector2MultiplyScalar(particle.direction, delta)
            particle.position = GLKVector2Add(particle.position, tmp)
            
            // Now apply the difference calculated early causing the particles to be relative in position to the emitter position
            particle.position = GLKVector2Add(particle.position, positionDifference)
        }
        
        // Update the particles color
        particle.color.r += (particle.deltaColor.r * delta)
        particle.color.g += (particle.deltaColor.g * delta)
        particle.color.b += (particle.deltaColor.b * delta)
        particle.color.a += (particle.deltaColor.a * delta)
        
        //        var c: GLKVector4
        //
        //        if (opacityModifyRGB) {
        //            c = GLKVector4Make(particle.color.r * particle.color.a,
        //                particle.color.g * particle.color.a,
        //                particle.color.b * particle.color.a,
        //                particle.color.a)
        //        } else {
        //            c = particle.color
        //        }
        
        // Update the particle size
        particle.particleSize += particle.particleSizeDelta * delta
        particle.particleSize = max(0, particle.particleSize)
        
        // Update the rotation of the particle
        particle.rotation += particle.rotationDelta * delta
        
        particles[index] = particle
        
    }
    
    func removeParticle(atIndex index : Int) {
        if index != particleCount - 1 {
            particles[index] = particles[particleCount - 1]
        }
        
        particleCount -= 1
    }
    
    func stopParticleEmitter() {
        active = false
        elapsedTime = 0
        emitCounter = 0
    }
    
    func reset() {
        active = true
        elapsedTime = 0
        
        for i in 0 ..< particleCount {
            particles[i].timeToLive = 0
        }
        
        emitCounter = 0;
        emissionRate = GLfloat(maxParticles) / particleLifespan
    }
    
    func addParticle() -> Bool {
        
        // If we have already reached the maximum number of particles then do nothing
        if particleCount == maxParticles {
            return false
        }
        
        // Take the next particle out of the particle pool we have created and initialize it
        self.initParticle(particle: &particles[particleCount])
        
        // Increment the particle count
        particleCount += 1
        
        // Return true to show that a particle has been created
        return true
    }
    
    func randomMinus1To1() -> GLfloat {
        return Float.random(in: -1.0...1.0)
    }
    
    func initParticle(particle : inout Particle) {
        
        // Init the position of the particle.  This is based on the source position of the particle emitter
        // plus a configured variance.  The RANDOM_MINUS_1_TO_1 macro allows the number to be both positive
        // and negative
        particle.position.x = sourcePosition.x + sourcePositionVariance.x * randomMinus1To1()
        particle.position.y = sourcePosition.y + sourcePositionVariance.y * randomMinus1To1()
        particle.startPos.x = sourcePosition.x
        particle.startPos.y = sourcePosition.y
        
        // Init the direction of the particle.  The newAngle is calculated using the angle passed in and the
        // angle variance.
        let newAngle : GLfloat = GLKMathDegreesToRadians(angle + angleVariance * randomMinus1To1())
        
        // Create a new GLKVector2 using the newAngle
        let vector : GLKVector2 = GLKVector2Make(cosf(newAngle), sinf(newAngle))
        
        // Calculate the vectorSpeed using the speed and speedVariance which has been passed in
        let vectorSpeed : GLfloat = speed + speedVariance * randomMinus1To1()
        
        // The particles direction vector is calculated by taking the vector calculated above and
        // multiplying that by the speed
        particle.direction = GLKVector2MultiplyScalar(vector, vectorSpeed)
        
        // Calculate the particles life span using the life span and variance passed in
        particle.timeToLive = max(0, particleLifespan + particleLifespanVariance * randomMinus1To1())
        
        // Set the default diameter of the particle from the source position
        particle.radius = maxRadius + maxRadiusVariance * randomMinus1To1()
        particle.radiusDelta = maxRadius / particle.timeToLive
        particle.angle = GLKMathDegreesToRadians(angle + angleVariance * randomMinus1To1())
        particle.degreesPerSecond = GLKMathDegreesToRadians(rotatePerSecond + rotatePerSecondVariance * randomMinus1To1())
        
        particle.radialAcceleration = radialAcceleration + radialAccelVariance * randomMinus1To1()
        particle.tangentialAcceleration = tangentialAcceleration + tangentialAccelVariance * randomMinus1To1()
        
        // Calculate the particle size using the start and finish particle sizes
        let particleStartSize : GLfloat = startParticleSize + startParticleSizeVariance * randomMinus1To1()
        let particleFinishSize : GLfloat = finishParticleSize + finishParticleSizeVariance * randomMinus1To1()
        particle.particleSizeDelta = ((particleFinishSize - particleStartSize) / particle.timeToLive)
        particle.particleSize = max(0, particleStartSize)
        
        // Calculate the color the particle should have when it starts its life.  All the elements
        // of the start color passed in along with the variance are used to calculate the star color
        var start : GLKVector4  = GLKVector4Make(0.0, 0.0, 0.0, 0.0)
        start.r = startColor.r + startColorVariance.r * randomMinus1To1()
        start.g = startColor.g + startColorVariance.g * randomMinus1To1()
        start.b = startColor.b + startColorVariance.b * randomMinus1To1()
        start.a = startColor.a + startColorVariance.a * randomMinus1To1()
        
        // Calculate the color the particle should be when its life is over.  This is done the same
        // way as the start color above
        var end : GLKVector4 = GLKVector4Make(0.0, 0.0, 0.0, 0.0)
        end.r = finishColor.r + finishColorVariance.r * randomMinus1To1()
        end.g = finishColor.g + finishColorVariance.g * randomMinus1To1()
        end.b = finishColor.b + finishColorVariance.b * randomMinus1To1()
        end.a = finishColor.a + finishColorVariance.a * randomMinus1To1()
        
        // Calculate the delta which is to be applied to the particles color during each cycle of its
        // life.  The delta calculation uses the life span of the particle to make sure that the
        // particles color will transition from the start to end color during its life time.  As the game
        // loop is using a fixed delta value we can calculate the delta color once saving cycles in the
        // update method
        
        particle.color = start
        particle.deltaColor.r = ((end.r - start.r) / particle.timeToLive)
        particle.deltaColor.g = ((end.g - start.g) / particle.timeToLive)
        particle.deltaColor.b = ((end.b - start.b) / particle.timeToLive)
        particle.deltaColor.a = ((end.a - start.a) / particle.timeToLive)
        
        // Calculate the rotation
        let startA : GLfloat = rotationStart + rotationStartVariance * randomMinus1To1()
        let endA : GLfloat = rotationEnd + rotationEndVariance * randomMinus1To1()
        particle.rotation = startA
        particle.rotationDelta = (endA - startA) / particle.timeToLive
    }
    
    func parse(particleConfig aConfig : Dictionary<String, AnyObject>) {
//
//    TBXMLElement *rootXMLElement = aConfig.rootXMLElement;
//
//    // Make sure we have a root element or we cant process this file
//    NSAssert(rootXMLElement, @"ERROR - ParticleEmitter: Could not find root element in particle config file.");
//
//
//    // Load all of the values from the XML file into the particle emitter.  The functions below are using the
//    // TBXMLAdditions category.  This adds convenience methods to TBXML to help cut down on the code in this method.
//    emitterType                 = TBXML_INT     (rootXMLElement, @"emitterType");
//    sourcePosition              = TBXML_VEC2    (rootXMLElement, @"sourcePosition");
//    sourcePositionVariance      = TBXML_VEC2    (rootXMLElement, @"sourcePositionVariance");
//    speed                       = TBXML_FLOAT   (rootXMLElement, @"speed");
//    speedVariance               = TBXML_FLOAT   (rootXMLElement, @"speedVariance");
//    particleLifespan            = TBXML_FLOAT   (rootXMLElement, @"particleLifeSpan");
//    particleLifespanVariance    = TBXML_FLOAT   (rootXMLElement, @"particleLifespanVariance");
//    angle                       = TBXML_FLOAT   (rootXMLElement, @"angle");
//    angleVariance               = TBXML_FLOAT   (rootXMLElement, @"angleVariance");
//    gravity                     = TBXML_VEC2    (rootXMLElement, @"gravity");
//    radialAcceleration          = TBXML_FLOAT   (rootXMLElement, @"radialAcceleration");
//    tangentialAcceleration      = TBXML_FLOAT   (rootXMLElement, @"tangentialAcceleration");
//    tangentialAccelVariance     = TBXML_FLOAT   (rootXMLElement, @"tangentialAccelVariance");
//    startColor                  = TBXML_VEC4    (rootXMLElement, @"startColor");
//    startColorVariance          = TBXML_VEC4    (rootXMLElement, @"startColorVariance");
//    finishColor                 = TBXML_VEC4    (rootXMLElement, @"finishColor");
//    finishColorVariance         = TBXML_VEC4    (rootXMLElement, @"finishColorVariance");
//    maxParticles                = TBXML_FLOAT   (rootXMLElement, @"maxParticles");
//    startParticleSize           = TBXML_FLOAT   (rootXMLElement, @"startParticleSize");
//    startParticleSizeVariance   = TBXML_FLOAT   (rootXMLElement, @"startParticleSizeVariance");
//    finishParticleSize          = TBXML_FLOAT   (rootXMLElement, @"finishParticleSize");
//    finishParticleSizeVariance  = TBXML_FLOAT   (rootXMLElement, @"finishParticleSizeVariance");
//    duration                    = TBXML_FLOAT   (rootXMLElement, @"duration");
//    blendFuncSource             = TBXML_INT     (rootXMLElement, @"blendFuncSource");
//    blendFuncDestination        = TBXML_INT     (rootXMLElement, @"blendFuncDestination");
//
//    // These paramters are used when you want to have the particles spinning around the source location
//    maxRadius                   = TBXML_FLOAT   (rootXMLElement, @"maxRadius");
//    maxRadiusVariance           = TBXML_FLOAT   (rootXMLElement, @"maxRadiusVariance");
//    minRadius                   = TBXML_FLOAT   (rootXMLElement, @"minRadius");
//    rotatePerSecond             = TBXML_FLOAT   (rootXMLElement, @"rotatePerSecond");
//    rotatePerSecondVariance     = TBXML_FLOAT   (rootXMLElement, @"rotatePerSecondVariance");
//    rotationStart               = TBXML_FLOAT   (rootXMLElement, @"rotationStart");
//    rotationStartVariance       = TBXML_FLOAT   (rootXMLElement, @"rotationStartVariance");
//    rotationEnd                 = TBXML_FLOAT   (rootXMLElement, @"rotationEnd");
//    rotationEndVariance         = TBXML_FLOAT   (rootXMLElement, @"rotationEndVariance");
//
//    // Calculate the emission rate
//    emissionRate                = maxParticles / particleLifespan;
//    emitCounter                 = 0;
//
//
//    // First thing to grab is the texture that is to be used for the point sprite
//    TBXMLElement *element = TBXML_CHILD(rootXMLElement, @"texture");
//    if (element) {
//    _textureFileName = TBXML_ATTRIB_STRING(element, @"name");
//    _textureFileData = TBXML_ATTRIB_STRING(element, @"data");
//
//    NSError *error;
//
//    if (_textureFileName && !_textureFileData.length) {
//    // Get path to resource
//    NSString *path = [[NSBundle mainBundle] pathForResource:_textureFileName ofType:nil];
//
//    // If no path is passed back then something is wrong
//    NSAssert1(path, @"Unable to find texture file: %@", path);
//
//    // Create a new texture which is going to be used as the texture for the point sprites. As there is
//    // no texture data in the file, this is done using an external image file
//    _tiffData = [[NSData alloc] initWithContentsOfFile:path options:NSDataReadingUncached error:&error];
//
//    // Throw assersion error if loading texture failed
//    NSAssert(!error, @"Unable to load texture");
//    }
//
//    // If texture data is present in the file then create the texture image from that data rather than an external file
//    else if (_textureFileData.length) {
//    // Decode compressed tiff data
//    _tiffData = [[[NSData alloc] initWithBase64EncodedString:_textureFileData] gzipInflate];
//    }
//
//
//    // Create a UIImage from the tiff data to extract colorspace and alpha info
//    UIImage *image = [UIImage imageWithData:_tiffData];
//    _cgImage = [image CGImage];
//    CGImageAlphaInfo info = CGImageGetAlphaInfo(image.CGImage);
//    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
//
//    // Detect if the image contains alpha data
//    _hasAlpha = ((info == kCGImageAlphaPremultipliedLast) ||
//    (info == kCGImageAlphaPremultipliedFirst) ||
//    (info == kCGImageAlphaLast) ||
//    (info == kCGImageAlphaFirst) ? YES : NO);
//
//    // Detect if alpha data is premultiplied
//    _premultiplied = colorSpace && _hasAlpha;
//
//    // Is opacity modification required
//    _opacityModifyRGB = NO;
//    if (blendFuncSource == GL_ONE && blendFuncDestination == GL_ONE_MINUS_SRC_ALPHA) {
//    if (_premultiplied)
//    _opacityModifyRGB = YES;
//    else {
//    blendFuncSource = GL_SRC_ALPHA;
//    blendFuncDestination = GL_ONE_MINUS_SRC_ALPHA;
//    }
//    }
//    }
//
//    [self loadTexture];
    }
    
    func loadTexture() {
        fatalError("loadTexture not implemented")
    }
    
    func setupArrays() {
        // Allocate the memory necessary for the particle emitter arrays
        particles = Array()
        
        // By default the particle emitter is active when created
        active = true
        
        // Set the particle count to zero
        particleCount = 0
        
        // Reset the elapsed time
        elapsedTime = 0
    }
    
}