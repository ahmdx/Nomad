/// Copyright 2021 Ahmed Mohamed
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
/// http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///

import XCTest
@testable import Nomad
import Version

final class TribeTargetTests: XCTestCase {
    func testEquality() {
        XCTAssertTrue(try (TribeTarget.first == TribeTarget.first))
        
        XCTAssertTrue(try (TribeTarget.always == TribeTarget.always))
        
        XCTAssertTrue(try (TribeTarget.literal("1.0.0") == TribeTarget.literal("1.0.0")))
        XCTAssertTrue(try (TribeTarget.literal("1.0.0+1") == TribeTarget.literal("1.0.0+2")))
    }
    
    func testInequality() {
        XCTAssertTrue(try (TribeTarget.first < TribeTarget.always))
        XCTAssertTrue(try (TribeTarget.first < TribeTarget.literal("0.0.0")))
        
        XCTAssertTrue(try (TribeTarget.literal("1.0.0") < TribeTarget.always))

        XCTAssertTrue(try (TribeTarget.literal("1.0.0") < TribeTarget.literal("2.0.0")))
        XCTAssertTrue(try (TribeTarget.literal("1.0.0-alpha") < TribeTarget.literal("1.0.0-beta")))
    }
    
    func testInvalidLiteralsEquality() {
        XCTAssertThrowsError(try (TribeTarget.literal("") == TribeTarget.literal("1.2.1")))
        XCTAssertThrowsError(try (TribeTarget.literal("1.0.0") == TribeTarget.literal("1.2")))
        
        XCTAssertThrowsError(try (TribeTarget.literal("XYZ") == TribeTarget.literal("1.2.0")))
        XCTAssertThrowsError(try (TribeTarget.literal("") == TribeTarget.literal("1.2.0")))
    }
    
    func testInvalidLiteralsInequality() {
        XCTAssertThrowsError(try (TribeTarget.literal("") < TribeTarget.literal("1.2.1")))
        XCTAssertThrowsError(try (TribeTarget.literal("1.0.0") < TribeTarget.literal("1.2")))
        
        XCTAssertThrowsError(try (TribeTarget.literal("XYZ") < TribeTarget.literal("1.2.0")))
        XCTAssertThrowsError(try (TribeTarget.literal("") < TribeTarget.literal("1.2.0")))
    }

    static var allTests = [
        ("testEquality", testEquality),
        ("testInequality", testInequality),
        ("testInvalidLiteralsEquality", testInvalidLiteralsEquality),
        ("testInvalidLiteralsInequality", testInvalidLiteralsInequality)
    ]
}
