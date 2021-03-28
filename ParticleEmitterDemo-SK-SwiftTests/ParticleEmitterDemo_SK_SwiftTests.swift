//
//  ParticleEmitterDemo_SK_SwiftTests.swift
//  ParticleEmitterDemo-SK-SwiftTests
//
//  Created by Peter Easdown on 27/3/21.
//  Copyright © 2021 71Squared Ltd. All rights reserved.
//

import XCTest
@testable import ParticleEmitterDemo_SK_Swift

class ParticleEmitterDemo_SK_SwiftTests: XCTestCase {

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
        let configFile = "Comet"
        
        do {
            let emitter = try BaseParticleEmitter.load(withFile: configFile)
            
            XCTAssertEqual(emitter?.particleLifespan, 0.1974)
        } catch {
            NSLog("failed to load emitter: \(error)")
            XCTFail()
        }
        
    }

}
