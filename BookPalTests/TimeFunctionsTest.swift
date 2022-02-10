//
//  TimeFunctionsTest.swift
//  BookPalTests
//
//  Created by Jan Kipka on 27.01.22.
//

import XCTest
import BookPal

class TimeFunctionsTest: XCTestCase {
    
    func testTimeIntervalExtension() throws {
        let timeInt = TimeInterval(0)
        let string = timeInt.asDaysHoursMinutesString
        XCTAssertNotNil(string)
        XCTAssertEqual("0min", string)
    }
    
    func testTimeIntervalExtensionDefault() throws {
        let timeInt = TimeInterval()
        let string = timeInt.asDaysHoursMinutesString
        XCTAssertNotNil(string)
        XCTAssertEqual("0min", string)
    }
    
    

}
