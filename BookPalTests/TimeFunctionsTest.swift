//
//  TimeFunctionsTest.swift
//  BookPalTests
//
//  Created by Jan Kipka on 27.01.22.
//

import XCTest
import BookPal

class TimeFunctionsTest: XCTestCase {
    
    func testAsHoursAndMinutesString() throws {
        let timeUnit = TimeUnit(year: 2021, month: 10, dayOfMonth: 10, hours: 12, minutes: 10, seconds: 30)
        XCTAssertEqual("12h 10m", timeUnit.asHoursMinutesString)
    }
    
    func testAsHoursAndMinutesStringRoundUp() throws {
        let timeUnit = TimeUnit(year: 2021, month: 10, dayOfMonth: 10, hours: 0, minutes: 1, seconds: 32)
        XCTAssertEqual("2m", timeUnit.asHoursMinutesString)
    }
    
    func testAsHoursAndMinutesStringRoundUpOnlySeconds() throws {
        let timeUnit = TimeUnit(year: 2021, month: 10, dayOfMonth: 10, hours: 0, minutes: 0, seconds: 32)
        XCTAssertEqual("1m", timeUnit.asHoursMinutesString)
    }
    
    func testTimeUnitAsString() throws {
        let timeUnit = TimeUnit(year: 2021, month: 10, dayOfMonth: 10, hours: 12, minutes: 10, seconds: 30)
        XCTAssertEqual("10.10.2021 12:10:30", timeUnit.asDateStringLong)
    }
    
    func testTimeUnitAsStringWithoutSeconds() throws {
        let timeUnit = TimeUnit(year: 2021, month: 10, dayOfMonth: 10, hours: 12, minutes: 10, seconds: nil)
        XCTAssertEqual("10.10.2021 12:10 Uhr", timeUnit.asDateStringShort)
    }
    
    func testTimeUnitAsStringMinutesUnderTen() throws {
        let timeUnit = TimeUnit(year: 2021, month: 10, dayOfMonth: 10, hours: 12, minutes: 4, seconds: nil)
        XCTAssertEqual("10.10.2021 12:04 Uhr", timeUnit.asDateStringShort)
    }
    
    func testGetZeitEinheitEmptyInterval() throws {
        let zeitEinheit = getTimeUnitFromTimeInterval(TimeInterval())
        XCTAssertNil(zeitEinheit)
    }
    
    func testGetZeitEinheitFromTimeIntervalHighValue() throws {
        let interval = TimeInterval(4830)
        
        let zeitEinheit = getTimeUnitFromTimeInterval(interval)
        
        XCTAssertTrue(zeitEinheit!.hours == 1)
        XCTAssertTrue(zeitEinheit!.minutes == 20)
        XCTAssertTrue(zeitEinheit!.seconds == 30)
    }
    
    func testGetZeitEinheitFromTimeIntervalValueBelowAnHour() throws {
        let interval = TimeInterval(2864)
        
        let zeitEinheit = getTimeUnitFromTimeInterval(interval)
        
        XCTAssertTrue(zeitEinheit!.hours == 0)
        XCTAssertTrue(zeitEinheit!.minutes == 47)
        XCTAssertTrue(zeitEinheit!.seconds == 44)
    }
    
    func testGetZeitEinheitFromTimeIntervalBelowTenMinutes() throws {
        let interval = TimeInterval(582)
        
        let zeitEinheit = getTimeUnitFromTimeInterval(interval)
        
        XCTAssertTrue(zeitEinheit!.hours == 0)
        XCTAssertTrue(zeitEinheit!.minutes == 9)
        XCTAssertTrue(zeitEinheit!.seconds == 42)
    }
    
    func testGetZeitEinheitFromTimeIntervalBelowOneMinute() throws {
        let interval = TimeInterval(58)
        
        let zeitEinheit = getTimeUnitFromTimeInterval(interval)
        
        XCTAssertTrue(zeitEinheit!.hours == 0)
        XCTAssertTrue(zeitEinheit!.minutes == 0)
        XCTAssertTrue(zeitEinheit!.seconds == 58)
    }

}
