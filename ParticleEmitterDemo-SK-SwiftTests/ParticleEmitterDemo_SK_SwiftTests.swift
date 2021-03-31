//
//  ParticleEmitterDemo_SK_SwiftTests.swift
//  ParticleEmitterDemo-SK-SwiftTests
//
//  Created by Peter Easdown on 27/3/21.
//  Copyright © 2021 71Squared Ltd. All rights reserved.
//

import XCTest
@testable import ParticleEmitterDemo_SK_Swift

class ParticleEmitterDemo_SK_SwiftTests: XCTestCase , BaseParticleEmitterDelegate {
    func removeParticle() {
        
    }
    
    func addParticle() {
        
    }
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //    func testBasic() {
    //
    //        let testxml = """
    //            <sysmsg type="paymsg">
    //                <paymsg>
    //                    <list>1</list>
    //                    <list>2</list>
    //                    <list>3</list>
    //                    <list>4</list>
    //                    <list>5</list>
    //                    <list>6</list>
    //                    <fromusername><![CDATA[mango1]]></fromusername>
    //                    <tousername><![CDATA[mango2]]></tousername>
    //                    <paymsgid><![CDATA[]]></paymsgid>
    //                </paymsg>
    //            </sysmsg>
    //            """
    //        if let dic = XmlReader.dictionaryForXMLData(data: testxml.data(using: .utf8)!) {
    //
    //            NSLog("\(dic)")
    //            XCTAssertNotNil(dic)
    //        } else {
    //            XCTFail()
    //        }
    //    }
    
    func testLoad() {
        let configFiles = [
            "Atomic Bubble",
            "Blue Flame",
            "Blue Galaxy",
            "Comet",
            "Crazy Blue",
            "Electrons",
            "Foam",
            "Into The Blue",
            "JasonChoi_Flash",
            "JasonChoi_Swirl01",
            "JasonChoi_rising up",
            "Meks Blood Spill",
            "Plasma Glow",
            "Real Popcorn",
            "Shooting Fireball",
            "The Sun",
            "Touch Up",
            "Trippy",
            "Winner Stars",
            "huo1",
            "wu1"
        ]
        
        
        do {
            try configFiles.forEach { (filename) in
                let emitter = try BaseParticleEmitter.load(withFile: filename, delegate: self)
                
                if filename.elementsEqual("Comet") {
                    XCTAssertEqual(emitter?.particleLifespan.float, 0.1974)
                    XCTAssertEqual(emitter?.startColor.r, 0.83)
                    XCTAssertEqual(emitter?.startParticleSize.float, 41.68)
                    XCTAssertEqual(emitter?.blendFuncSource.int, 770)
                    XCTAssertEqual(emitter?.duration.float, -1.0)
                } else if filename.elementsEqual("Winner Stars") {
                    XCTAssertEqual(emitter?.sourcePosition.x, 150.00)
                    XCTAssertEqual(emitter?.sourcePosition.y, 50.00)
                    XCTAssertEqual(emitter?.sourcePositionVariance.x, 0.00)
                    XCTAssertEqual(emitter?.sourcePositionVariance.y, 0.00)
                    XCTAssertEqual(emitter?.speed.float, 348.68)
                    XCTAssertEqual(emitter?.speedVariance.float, 0.00)
                    XCTAssertEqual(emitter?.particleLifespan.float, 1.3816)
                    XCTAssertEqual(emitter?.particleLifespanVariance.float, 0.0000)
                    XCTAssertEqual(emitter?.angle.float, 360.00)
                    XCTAssertEqual(emitter?.angleVariance.float, 310.26)
                    XCTAssertEqual(emitter?.gravity.x, 0.0)
                    XCTAssertEqual(emitter?.gravity.x, 0.0)
                    XCTAssertEqual(emitter?.radialAcceleration.float, -1000.00)
                    XCTAssertEqual(emitter?.tangentialAcceleration.float, -302.63)
                    XCTAssertEqual(emitter?.radialAccelVariance.float, 0.00)
                    XCTAssertEqual(emitter?.tangentialAccelVariance.float, 0.00)
                    XCTAssertEqual(emitter?.startColor.r, 1.00)
                    XCTAssertEqual(emitter?.startColor.g, 0.40)
                    XCTAssertEqual(emitter?.startColor.b, 0.76)
                    XCTAssertEqual(emitter?.startColor.a, 0.48)
                    XCTAssertEqual(emitter?.startColorVariance.r, 1.00)
                    XCTAssertEqual(emitter?.startColorVariance.g, 1.00)
                    XCTAssertEqual(emitter?.startColorVariance.b, 1.00)
                    XCTAssertEqual(emitter?.startColorVariance.a, 1.00)
                    XCTAssertEqual(emitter?.finishColor.r, 0.00)
                    XCTAssertEqual(emitter?.finishColor.g, 0.60)
                    XCTAssertEqual(emitter?.finishColor.b, 0.46)
                    XCTAssertEqual(emitter?.finishColor.a, 0.85)
                    XCTAssertEqual(emitter?.finishColorVariance.r, 1.00)
                    XCTAssertEqual(emitter?.finishColorVariance.g, 1.00)
                    XCTAssertEqual(emitter?.finishColorVariance.b, 1.00)
                    XCTAssertEqual(emitter?.finishColorVariance.a, 1.00)
                    XCTAssertEqual(emitter?.maxParticles.int, 486)
                    XCTAssertEqual(emitter?.startParticleSize.float, 3.37)
                    XCTAssertEqual(emitter?.startParticleSizeVariance.float, 64.00)
                    XCTAssertEqual(emitter?.finishParticleSize.float, 3.37)
                    XCTAssertEqual(emitter?.finishParticleSizeVariance.float, 0.00)
                    XCTAssertEqual(emitter?.duration.float, -1.00)
                    XCTAssertEqual(emitter?.emitterType.rawValue, 0)
                    XCTAssertEqual(emitter?.maxRadius.float, 0.00)
                    XCTAssertEqual(emitter?.maxRadiusVariance.float, 0.00)
                    XCTAssertEqual(emitter?.minRadius.float, 300.00)
                    XCTAssertEqual(emitter?.rotatePerSecond.float, 360.00)
                    XCTAssertEqual(emitter?.rotatePerSecondVariance.float, 0.00)
                    XCTAssertEqual(emitter?.blendFuncSource.int, 770)
                    XCTAssertEqual(emitter?.blendFuncDestination.int, 1)
                    XCTAssertEqual(emitter?.rotationStart.float, 142.11)
                    XCTAssertEqual(emitter?.rotationStartVariance.float, -236.84)
                    XCTAssertEqual(emitter?.rotationEnd.float, 0.00)
                    XCTAssertEqual(emitter?.rotationEndVariance.float, 0.00)
                }
                
                if let texture = emitter?.textureDetails!.texture() {
                    XCTAssertNotEqual(texture.size().width, 0.0)
                    XCTAssertNotEqual(texture.size().height, 0.0)
                } else {
                    XCTFail()
                }
            }
        } catch {
            NSLog("failed to load emitter: \(error)")
            XCTFail()
        }
        
    }
    
}
