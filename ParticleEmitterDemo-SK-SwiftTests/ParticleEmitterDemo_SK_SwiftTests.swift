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
    func removeParticle(atIndex index: Int) {
    
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
                
                if filename.elementsEqual("Comet.pex") {
                    XCTAssertEqual(emitter?.particleLifespan.float, 0.1974)
                    XCTAssertEqual(emitter?.startColor.r, 0.83)
                    XCTAssertEqual(emitter?.startParticleSize.float, 41.68)
                    XCTAssertEqual(emitter?.blendFuncSource.int, 770)
                    XCTAssertEqual(emitter?.duration.float, -1.0)
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
