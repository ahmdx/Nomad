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
import PromiseKit
@testable import Nomad

final class NomadTests: XCTestCase {    
    override class func tearDown() {
        UserDefaults.standard.synchronize()
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: Constants.currentTarget.rawValue)
    }
    
    func testColdStart() {
        XCTAssertEqual(Nomad.currentTarget, .first)
    }
    
    func testValidTribesAudit() {
        let invalidTribes = Nomad.audit(tribes: [Tribe_2_1_0.self, Tribe_1_0_15.self, Tribe_0_0_1.self, Tribe_First.self, Tribe_Always.self])
        
        XCTAssertEqual(invalidTribes.count, 0)
    }
    
    func testInvalidTribesAudit() {
        let invalidTribes = Nomad.audit(tribes: [Tribe_2_1_0.self, Tribe_1_0_15.self, Tribe_0_0_1.self, Tribe_First.self, Tribe_Always.self, Tribe_InvalidLiteral.self])
        
        XCTAssertEqual(invalidTribes.count, 1)
    }
    
    func testTribeMigration() {
        let expectation = XCTestExpectation()
        
        Nomad.pack(with: [Tribe_2_1_0.self, Tribe_1_0_15.self, Tribe_0_0_1.self, Tribe_First.self, Tribe_Always.self])
            .migrate()
            .done {
                XCTAssertEqual(Nomad.currentTarget, .literal("2.1.0"))
                
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testTribeMigrationSkip() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        Nomad.pack(with: [Tribe_2_1_0.self, Tribe_1_0_15.self, Tribe_0_0_1.self, Tribe_3_1_0.self])
            .migrate()
            .then { _ -> Promise<Void> in
                XCTAssertEqual(Nomad.currentTarget, .literal("3.1.0"))
                
                expectation.fulfill()
                
                // Skips a throwing tribe having target `3.0.0`
                return Nomad.pack(with: [Tribe_2_1_0.self, Tribe_1_0_15.self, Tribe_0_0_1.self, Tribe_3_1_0.self, Tribe_Throws.self])
                    .migrate()
            }
            .done {
                XCTAssertEqual(Nomad.currentTarget, .literal("3.1.0"))
                
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testThrowingTribeMigration() {
        let expectation = XCTestExpectation()
        
        Nomad.pack(with: [Tribe_2_1_0.self, Tribe_1_0_15.self, Tribe_Throws.self]).migrate()
            .catch { _ in
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    static var allTests = [
        ("testColdStart", testColdStart),
        ("testValidTribesAudit", testValidTribesAudit),
        ("testInvalidTribesAudit", testInvalidTribesAudit),
        ("testTribeMigration", testTribeMigration),
        ("testTribeMigrationSkip", testTribeMigrationSkip),
        ("testThrowingTribeMigration", testThrowingTribeMigration)
    ]
}
