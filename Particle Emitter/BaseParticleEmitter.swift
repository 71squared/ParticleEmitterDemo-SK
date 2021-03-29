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
import Gzip
import XMLCoder

// Particle type
enum ParticleTypes : Int, Codable, DynamicNodeDecoding {
    
    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .attribute
    }
    
    case particleTypeGravity
    case particleTypeRadial
    
    enum CodingKeys: String, CodingKey {
        case value
    }
    
    enum DecodeError : Error {
        case ParticleTypeError
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let value = try? values.decode(Int.self, forKey: .value) {
            self = ParticleTypes(rawValue: value)!
            return
        }
        
        if let value = try? values.decode(String.self, forKey: .value) {
            self = ParticleTypes(rawValue: Int(value)!)!
            return
        }
        
        throw DecodeError.ParticleTypeError
    }
    
}

// Structure that holds the location and size for each point sprite
struct PointSprite {
    var x     : PEFloat = .init(0.0)
    var y     : PEFloat = .init(0.0)
    var s     : PEFloat = .init(0.0)
    var t     : PEFloat = .init(0.0)
    var color : Vector4 = .zero
}

struct TexturedColoredVertex {
    var vertex              : Vector2 = .zero
    var texture             : Vector2 = .zero
    var color               : Vector4 = .zero
    var particleSize        : PEFloat = .init(0.0)
    var rotationRad         : PEFloat = .init(0.0)
    var positionMultiplier  : Vector2 = .zero
}

struct ParticleQuad {
    var bl : TexturedColoredVertex
    var br : TexturedColoredVertex
    var tl : TexturedColoredVertex
    var tr : TexturedColoredVertex
}

// Structure used to hold particle specific information
struct Particle {
    var position                : Vector2 = .zero
    var direction               : Vector2 = .zero
    var startPos                : Vector2 = .zero
    var color                   : Vector4 = .zero
    var deltaColor              : Vector4 = .zero
    var rotation                : PEFloat = .init(0.0)
    var rotationDelta           : PEFloat = .init(0.0)
    var radialAcceleration      : PEFloat = .init(0.0)
    var tangentialAcceleration  : PEFloat = .init(0.0)
    var radius                  : PEFloat = .init(0.0)
    var radiusDelta             : PEFloat = .init(0.0)
    var angle                   : PEFloat = .init(0.0)
    var degreesPerSecond        : PEFloat = .init(0.0)
    var particleSize            : PEFloat = .init(0.0)
    var particleSizeDelta       : PEFloat = .init(0.0)
    var timeToLive              : PEFloat = .init(0.0)
}

// The particleEmitter allows you to define parameters that are used when generating particles.
// These particles are SpriteKit particle sprites that based on the parameters provided each have
// their own characteristics such as speed, lifespan, start and end colors etc.  Using these
// particle emitters allows you to create organic looking effects such as smoke, fire and
// explosions.
//

struct Vector2 : Codable, DynamicNodeDecoding {
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .attribute
    }
    
    var x : Float
    var y : Float
    
    enum CodingKeys : String, CodingKey {
        case x
        case y
    }
    
    static var zero : Vector2 {
        get {
            return .init(0.0, 0.0)
        }
    }
    
    func asGLVector2() -> GLKVector2 {
        return GLKVector2Make(x, y)
    }
    
    init(_ x: PEFloat, _ y: PEFloat) {
        self.x = x.float
        self.y = y.float
    }
    
    init(_ x: Double, _ y: Double) {
        self.x = .init(x)
        self.y = .init(y)
    }
    
    init(_ x: Float, _ y: Float) {
        self.x = .init(x)
        self.y = .init(y)
    }
    
    init(_ glVec: GLKVector2) {
        self.x = .init(glVec.x)
        self.y = .init(glVec.y)
    }
    
    static func -(left : Vector2, right: Vector2) -> Vector2 {
        return Vector2(left.x - right.x, left.y - right.y)
    }
    
    static func +(left : Vector2, right: Vector2) -> Vector2 {
        return Vector2(left.x + right.x, left.y + right.y)
    }
}

struct Vector4 : Codable, DynamicNodeDecoding {
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .attribute
    }
    
    var r : Float
    var g : Float
    var b : Float
    var a : Float
    
    enum CodingKeys : String, CodingKey {
        case r = "red"
        case g = "green"
        case b = "blue"
        case a = "alpha"
    }
    
    init(_ r: Float, _ g: Float, _ b: Float, _ a: Float) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    static var zero : Vector4 {
        get {
            return .init(0.0, 0.0, 0.0, 0.0)
        }
    }
    
    func asGLVector4() -> GLKVector4 {
        return GLKVector4Make(r, g, b, a)
    }
    
    func asUIColor() -> UIColor {
        return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }
}

struct PEInt : Codable, DynamicNodeDecoding {
    
    var value : Int
    
    enum CodingKeys : String, CodingKey {
        case value
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .attribute
    }
    
    init(_ val: Int) {
        self.value = val
    }
    
    var int : Int {
        get {
            return value
        }
        
        set {
            value = newValue
        }
    }
    
}

struct PEFloat : Codable, DynamicNodeDecoding {
    
    var value : Float
    
    enum CodingKeys : String, CodingKey {
        case value
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .attribute
    }
    
    var float : Float {
        get {
            return value
        }
        
        set {
            value = newValue
        }
    }
    
    init(_ val: Float) {
        value = val
    }
    
    init(_ val: Double) {
        value = Float(val)
    }
    
    static func +(left : PEFloat, right: PEFloat) -> PEFloat {
        return PEFloat(left.value + right.value)
    }
    
    static func +(left : Float, right: PEFloat) -> PEFloat {
        return PEFloat(left + right.value)
    }
    
    static func +(left : PEFloat, right: Float) -> PEFloat {
        return PEFloat(left.value + right)
    }
    
    static func +=( left : inout PEFloat, right: PEFloat) {
        left.value += right.value
    }
    
    static func -(left : PEFloat, right: PEFloat) -> PEFloat {
        return PEFloat(left.value - right.value)
    }
    
    static func -(left : Float, right: PEFloat) -> PEFloat {
        return PEFloat(left - right.value)
    }
    
    static func -(left : PEFloat, right: Float) -> PEFloat {
        return PEFloat(left.value - right)
    }
    
    static func -=( left : inout PEFloat, right: PEFloat) {
        left.value -= right.value
    }
    
    static func *(left : PEFloat, right: PEFloat) -> PEFloat {
        return PEFloat(left.value * right.value)
    }
    
    static func *(left : Float, right: PEFloat) -> PEFloat {
        return PEFloat(left * right.value)
    }
    
    static func *(left : PEFloat, right: Float) -> PEFloat {
        return PEFloat(left.value * right)
    }
    
    static func /(left : PEFloat, right: PEFloat) -> PEFloat {
        return PEFloat(left.value / right.value)
    }
    
    static func /(left : Float, right: PEFloat) -> PEFloat {
        return PEFloat(left / right.value)
    }
    
    static func /(left : PEFloat, right: Float) -> PEFloat {
        return PEFloat(left.value / right)
    }
    
    static func >(left : PEFloat, right: PEFloat) -> Bool {
        return left.value > right.value
    }
    
    static func >(left : PEFloat, right: Float) -> Bool {
        return left.value > right
    }
    
    static func <(left : PEFloat, right: PEFloat) -> Bool {
        return left.value < right.value
    }
    
    static func >=(left : PEFloat, right: PEFloat) -> Bool {
        return left.value >= right.value
    }
    
    static func <=(left : PEFloat, right: PEFloat) -> Bool {
        return left.value <= right.value
    }
    
    static func ==(left : PEFloat, right: PEFloat) -> Bool {
        return left.value == right.value
    }
    
    static func !=(left : PEFloat, right: PEFloat) -> Bool {
        return left.value != right.value
    }
    
    static func !=(left : Float, right: PEFloat) -> Bool {
        return left != right.value
    }
    
    static func !=(left : PEFloat, right: Float) -> Bool {
        return left.value != right
    }
    
}

struct PETexture : Codable, DynamicNodeDecoding {
    
    var name : String
    var data : String
    
    enum CodingKeys : String, CodingKey {
        case name
        case data
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .attribute
    }
    
    func inflated(data: Data) -> Data {
        if data.count == 0 {
            return data
        }
        
        do {
            return try data.gunzipped()
        } catch {
            print(error.localizedDescription)
            
            return Data()
        }
    }
    
    func image() -> UIImage? {
        if name.count > 0 && data.count == 0 {
            return UIImage(named: name)
        } else if data.count > 0 {
            let tiffData = self.inflated(data: Data(base64Encoded: data)!)
            
            return UIImage(data: tiffData)
        }
        
        return nil
    }
    
    func texture() -> SKTexture? {
        if let image = self.image() {
            return SKTexture(image: image)
        }
        
        return nil
    }
}

protocol BaseParticleEmitterDelegate {
    func addParticle()
    func removeParticle(atIndex index : Int)
}

class BaseParticleEmitter : Codable, DynamicNodeEncoding, DynamicNodeDecoding {
    
    /// Delegate
    ///
    var delegate : BaseParticleEmitterDelegate?
    
    /// Flags to enable/disable functionality
    private var updateParticlePositionAndRotation : Bool = true
    
    /// Particle vars
    var textureDetails : PETexture?
    var tiffData : Data?
    var image : UIImage?
    var cgImage : CGImage?
    var emitterType : ParticleTypes = .particleTypeGravity
    var sourcePositionVariance : Vector2 = .zero
    var angle : PEFloat = .init(0.0)
    var angleVariance : PEFloat = .init(0.0)
    var speed : PEFloat = .init(0.0)
    var speedVariance : PEFloat = .init(0.0)
    var radialAcceleration : PEFloat = .init(0.0)
    var tangentialAcceleration : PEFloat = .init(0.0)
    var radialAccelVariance : PEFloat = .init(0.0)
    var tangentialAccelVariance : PEFloat = .init(0.0)
    var gravity : Vector2 = .zero
    var particleLifespan : PEFloat = .init(0.0)
    var particleLifespanVariance : PEFloat = .init(0.0)
    var startColor : Vector4 = .zero
    var startColorVariance : Vector4 = .zero
    var finishColor : Vector4 = .zero
    var finishColorVariance : Vector4 = .zero
    var startParticleSize : PEFloat = .init(0.0)
    var startParticleSizeVariance : PEFloat = .init(0.0)
    var finishParticleSize : PEFloat = .init(0.0)
    var finishParticleSizeVariance : PEFloat = .init(0.0)
    var maxParticles : PEInt = .init(0)
    var emissionRate : PEFloat = .init(0.0)
    var emitCounter : PEFloat = .init(0.0)
    var elapsedTime : PEFloat = .init(0.0)
    var rotationStart : PEFloat = .init(0.0)
    var rotationStartVariance : PEFloat = .init(0.0)
    var rotationEnd : PEFloat = .init(0.0)
    var rotationEndVariance : PEFloat = .init(0.0)
    var vertexArrayName : GLuint = 0
    var blendFuncSource : PEInt = PEInt(0)
    var blendFuncDestination : PEInt = PEInt(0)
    var opacityModifyRGB : Bool = false
    var premultiplied : Bool = false
    var hasAlpha : Bool = true
    
    /// Particle vars only used when a maxRadius value is provided.  These values are used for
    /// the special purpose of creating the spinning portal emitter
    var maxRadius : PEFloat  = .init(0.0)               /// Max radius at which particles are drawn when rotating
    var maxRadiusVariance : PEFloat = .init(0.0)        /// Variance of the maxRadius
    var radiusSpeed : PEFloat = .init(0.0)              /// The speed at which a particle moves from maxRadius to minRadius
    var minRadius : PEFloat = .init(0.0)                /// Radius from source below which a particle dies
    var rotatePerSecond : PEFloat = .init(0.0)          /// Number of degress to rotate a particle around the source pos per second
    var rotatePerSecondVariance : PEFloat = .init(0.0)  /// Variance in degrees for rotatePerSecond
    
    /// Particle Emitter Vars
    var active : Bool = false
    var vertexIndex : GLint = 0              /// Stores the index of the vertices being used for each particle
    
    /// Render
    var particles = Array<Particle>()         /// Array of particles that hold the particle emitters particle details
    private var quads = Array<ParticleQuad>()
    private var quads2 = Array<ParticleQuad>() /// Array holding quad information for each particle : ParticleQuad
    
    
    var sourcePosition : Vector2 = .zero
    var particleCount : Int = 0
    var duration : PEFloat = .init(0.0)
    
    deinit {
        // Release the memory we are using for our vertex and particle arrays etc
        // If vertices or particles exist then free them
        self.quads.removeAll()
        self.quads2.removeAll()
        self.particles.removeAll()
    }
    
    static func load(withFile: String, delegate: BaseParticleEmitterDelegate) throws -> BaseParticleEmitter? {
        if let fileURL = Bundle.main.url(forResource: withFile, withExtension: "pex") {
            let data = try Data(contentsOf: fileURL)

            let decoder = XMLDecoder()
            
            let result = try decoder.decode(BaseParticleEmitter.self,from: data)

            result.delegate = delegate
            
            result.postParseInit()
            
            return result
        }
        
        return nil
    }
    
    func update(withDelta aDelta: PEFloat) {
        
        // If the emitter is active and the emission rate is greater than zero then emit particles
        if active && (emissionRate > 0) {
            let rate : PEFloat = 1.0 / emissionRate
            
            if (particleCount < maxParticles.int) {
                emitCounter += aDelta
            }
            
            while (particleCount < maxParticles.int && emitCounter > rate) {
                self.addParticle()
                
                emitCounter -= rate
            }
            
            elapsedTime += aDelta
            
            if (duration != -1.0 && duration < elapsedTime) {
                self.stopParticleEmitter()
            }
        }
        
        // Reset the particle index before updating the particles in this emitter
        var index : Int = 0;
        
        // Loop through all the particles updating their location and color
        while index < particleCount {
            
            // Get the particle for the current particle index
            // Reduce the life span of the particle
            particles[index].timeToLive -= aDelta
            
            // If the current particle is alive then update it
            if particles[index].timeToLive > 0 {
                
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
    
    func updateParticle(atIndex index : Int, withDelta delta : PEFloat) {
        
        // Get the particle for the current particle index
        var particle : Particle = particles[index]
        
        // If maxRadius is greater than 0 then the particles are going to spin otherwise they are effected by speed and gravity
        if emitterType == .particleTypeRadial {
            
            // FIX 2
            // Update the angle of the particle from the sourcePosition and the radius.  This is only done of the particles are rotating
            particle.angle += particle.degreesPerSecond * delta
            particle.radius -= particle.radiusDelta * delta
            
            particle.position = Vector2(sourcePosition.x - cosf(particle.angle.float) * particle.radius, sourcePosition.y - sinf(particle.angle.float) * particle.radius)
            
            if (particle.radius < minRadius) {
                particle.timeToLive = .init(0.0)
            }
            
        } else {
            var tmp, radial, tangential : GLKVector2
            
            radial = GLKVector2Make(0.0, 0.0)
            
            // By default this emitters particles are moved relative to the emitter node position
            particle.position = particle.position - particle.startPos
            
            if particle.position.x > 0.0 || particle.position.y > 0.0 {
                radial = GLKVector2Normalize(particle.position.asGLVector2())
            }
            
            tangential = radial
            radial = GLKVector2MultiplyScalar(radial, particle.radialAcceleration.float)
            
            let newy = tangential.x
            tangential.x = -tangential.y
            tangential.y = newy
            tangential = GLKVector2MultiplyScalar(tangential, particle.tangentialAcceleration.float)
            
            tmp = GLKVector2Add( GLKVector2Add(radial, tangential), gravity.asGLVector2())
            tmp = GLKVector2MultiplyScalar(tmp, delta.float)
            particle.direction = particle.direction + Vector2(tmp)
            tmp = GLKVector2MultiplyScalar(particle.direction.asGLVector2(), delta.float)
            particle.position = particle.position + Vector2(tmp)
        }
        
        // Update the particles color
        particle.color.r += (particle.deltaColor.r * delta.float)
        particle.color.g += (particle.deltaColor.g * delta.float)
        particle.color.b += (particle.deltaColor.b * delta.float)
        particle.color.a += (particle.deltaColor.a * delta.float)
        
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
        particle.particleSize.float = max(0.0, particle.particleSize.float)
        
        // Update the rotation of the particle
        particle.rotation += particle.rotationDelta * delta
        
        particles[index] = particle
    }
    
    func removeParticle(atIndex index : Int) {
        if index != particleCount - 1 {
            particles[index] = particles[particleCount - 1]
        }
        
        particleCount -= 1
        
        delegate?.removeParticle(atIndex: index)
    }
    
    func stopParticleEmitter() {
        active = false
        elapsedTime.float = 0.0
        emitCounter.float = 0.0
    }
    
    func reset() {
        active = true
        elapsedTime.float = 0.0
        
        for i in 0 ..< particleCount {
            particles[i].timeToLive.float = 0.0
        }
        
        emitCounter.float = 0.0
        emissionRate = GLfloat(maxParticles.int) / particleLifespan
    }
    
    func addParticle() {
        
        // If we have already reached the maximum number of particles then do nothing
        if particleCount == maxParticles.int {
            return
        }
        
        // Take the next particle out of the particle pool we have created and initialize it
        self.initParticle(particle: &particles[particleCount])
        
        // Increment the particle count
        particleCount += 1

        // tell the delegate to add it's corresponding visualisation.
        self.delegate?.addParticle()
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
        let newAngle : GLfloat = GLKMathDegreesToRadians(angle.float + angleVariance.float * randomMinus1To1())
        
        // Create a new GLKVector2 using the newAngle
        let vector : GLKVector2 = GLKVector2Make(cosf(newAngle), sinf(newAngle))
        
        // Calculate the vectorSpeed using the speed and speedVariance which has been passed in
        let vectorSpeed : GLfloat = (speed + speedVariance).float * randomMinus1To1()
        
        // The particles direction vector is calculated by taking the vector calculated above and
        // multiplying that by the speed
        particle.direction = Vector2(GLKVector2MultiplyScalar(vector, vectorSpeed))
        
        // Calculate the particles life span using the life span and variance passed in
        particle.timeToLive = PEFloat(max(0, particleLifespan.float + particleLifespanVariance.float * randomMinus1To1()))
        
        // Set the default diameter of the particle from the source position
        particle.radius = maxRadius + maxRadiusVariance * randomMinus1To1()
        particle.radiusDelta = maxRadius / particle.timeToLive
        particle.angle.float = GLKMathDegreesToRadians(angle.float + angleVariance.float * randomMinus1To1())
        particle.degreesPerSecond.float = GLKMathDegreesToRadians(rotatePerSecond.float + rotatePerSecondVariance.float * randomMinus1To1())
        
        particle.radialAcceleration = radialAcceleration + radialAccelVariance * randomMinus1To1()
        particle.tangentialAcceleration = tangentialAcceleration + tangentialAccelVariance * randomMinus1To1()
        
        // Calculate the particle size using the start and finish particle sizes
        let particleStartSize : GLfloat = startParticleSize.float + startParticleSizeVariance.float * randomMinus1To1()
        let particleFinishSize : GLfloat = finishParticleSize.float + finishParticleSizeVariance.float * randomMinus1To1()
        particle.particleSizeDelta.float = ((particleFinishSize - particleStartSize) / particle.timeToLive.float)
        particle.particleSize.float = max(0, particleStartSize)
        
        // Calculate the color the particle should have when it starts its life.  All the elements
        // of the start color passed in along with the variance are used to calculate the star color
        var start : Vector4  = Vector4(0.0, 0.0, 0.0, 0.0)
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
        particle.deltaColor.r = ((end.r - start.r) / particle.timeToLive.float)
        particle.deltaColor.g = ((end.g - start.g) / particle.timeToLive.float)
        particle.deltaColor.b = ((end.b - start.b) / particle.timeToLive.float)
        particle.deltaColor.a = ((end.a - start.a) / particle.timeToLive.float)
        
        // Calculate the rotation
        let startA : GLfloat = rotationStart.float + rotationStartVariance.float * randomMinus1To1()
        let endA : GLfloat = rotationEnd.float + rotationEndVariance.float * randomMinus1To1()
        particle.rotation.float = startA
        particle.rotationDelta = (endA - startA) / particle.timeToLive
    }
    
    func setupArrays() {
        // Allocate the memory necessary for the particle emitter arrays
        particles = Array<Particle>(repeating: Particle(), count: maxParticles.int)
        
        // By default the particle emitter is active when created
        active = true
        
        // Set the particle count to zero
        particleCount = 0
        
        // Reset the elapsed time
        elapsedTime.float = 0
    }
    
    // MARK: - Codable
    
    enum CodingKeys : String, CodingKey {
        case emitterType
        case sourcePosition
        case sourcePositionVariance
        case speed
        case speedVariance
        case particleLifespan = "particleLifeSpan"
        case particleLifespanVariance
        case angle
        case angleVariance
        case gravity
        case radialAcceleration
        case tangentialAcceleration
        case tangentialAccelVariance
        case startColor
        case startColorVariance
        case finishColor
        case finishColorVariance
        case maxParticles
        case startParticleSize
        case startParticleSizeVariance
        case finishParticleSize
        case finishParticleSizeVariance
        case duration
        case blendFuncSource
        case blendFuncDestination
        case maxRadius
        case maxRadiusVariance
        case minRadius
        case rotatePerSecond
        case rotatePerSecondVariance
        case rotationStart
        case rotationStartVariance
        case rotationEnd
        case rotationEndVariance
        case textureDetails = "texture"
    }
    
    enum ConfigCodingKeys : String, CodingKey {
        case particleEmitterConfig
    }
    
    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        return .attribute
    }
    
    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .elementOrAttribute
    }

    private func postParseInit() {
        // Calculate the emission rate
        emissionRate.float = Float(maxParticles.int) / particleLifespan.float
        emitCounter.float = 0
        
        // Create a UIImage from the tiff data to extract colorspace and alpha info
        if let image = self.textureDetails?.image() {
            
            if let cgImage = image.cgImage {
                let info = cgImage.alphaInfo
                let space = cgImage.colorSpace
                
                // Detect if the image contains alpha data
                self.hasAlpha = info == .premultipliedLast ||
                    info == .premultipliedFirst ||
                    info == .last ||
                    info == .first
                
                // Detect if alpha data is premultiplied
                self.premultiplied = space != .none && self.hasAlpha
            }
        }
        
        // Is opacity modification required
        opacityModifyRGB = false
        
        if (blendFuncSource.int == GL_ONE && blendFuncDestination.int == GL_ONE_MINUS_SRC_ALPHA) {
            if premultiplied {
                opacityModifyRGB = true
            } else {
                blendFuncSource.int = Int(GL_SRC_ALPHA)
                blendFuncDestination.int = Int(GL_ONE_MINUS_SRC_ALPHA)
            }
        }
        
        self.setupArrays()
        self.reset()
    }
}
