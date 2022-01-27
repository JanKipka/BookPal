//
//  TimeFunctionsTest.swift
//  BookPalTests
//
//  Created by Jan Kipka on 27.01.22.
//

import XCTest
import BookPal

class TimeFunctionsTest: XCTestCase {
    
    func testGetZeitEinheitFromTimeIntervalHighValue() throws {
        let interval = TimeInterval(4830)
        
        let zeitEinheit = getTimeUnitFromTimeInterval(interval)
        
        XCTAssertTrue(zeitEinheit.hours == 1)
        XCTAssertTrue(zeitEinheit.minutes == 20)
        XCTAssertTrue(zeitEinheit.seconds == 30)
    }
    
    func testGetZeitEinheitFromTimeIntervalValueBelowAnHour() throws {
        let interval = TimeInterval(2864)
        
        let zeitEinheit = getTimeUnitFromTimeInterval(interval)
        
        XCTAssertTrue(zeitEinheit.hours == 0)
        XCTAssertTrue(zeitEinheit.minutes == 47)
        XCTAssertTrue(zeitEinheit.seconds == 44)
    }
    
    func testGetZeitEinheitFromTimeIntervalBelowTenMinutes() throws {
        let interval = TimeInterval(582)
        
        let zeitEinheit = getTimeUnitFromTimeInterval(interval)
        
        XCTAssertTrue(zeitEinheit.hours == 0)
        XCTAssertTrue(zeitEinheit.minutes == 9)
        XCTAssertTrue(zeitEinheit.seconds == 42)
    }
    
    func testGetZeitEinheitFromTimeIntervalBelowOneMinute() throws {
        let interval = TimeInterval(58)
        
        let zeitEinheit = getTimeUnitFromTimeInterval(interval)
        
        XCTAssertTrue(zeitEinheit.hours == 0)
        XCTAssertTrue(zeitEinheit.minutes == 0)
        XCTAssertTrue(zeitEinheit.seconds == 58)
    }

}
