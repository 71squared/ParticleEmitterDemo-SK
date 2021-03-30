//
//  BaseParticleEmitterDecodingTypes.swift
//  ParticleEmitterDemo-SK
//
//  Created by Peter Easdown on 30/3/21.
//  Copyright © 2021 71Squared Ltd. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit
import Gzip
import XMLCoder

// Particle type
extension ParticleTypes : Codable, DynamicNodeDecoding {
    
    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .attribute
    }
    
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
