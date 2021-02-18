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

final class NomadDelegateTests: XCTestCase {    
    override class func tearDown() {
        UserDefaults.standard.synchronize()
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: Constants.currentTarget.rawValue)
    }
    
    func testTribeMigration() {
        let willStartMigrationExpectation = XCTestExpectation()
        let didMigrateToExpectation = XCTestExpectation()
        didMigrateToExpectation.expectedFulfillmentCount = 4
        let didFinishMigrationExpectation = XCTestExpectation()
        let didInterruptMigrationExpectation = XCTestExpectation()
        didInterruptMigrationExpectation.isInverted = true
        
        let mockDelegate = MockNomadDelegate(willStartMigrationExpectation,
                                             didMigrateToExpectation,
                                             didFinishMigrationExpectation,
                                             didInterruptMigrationExpectation)
        
        Nomad.set(delegate: mockDelegate)
        let _ = Nomad.pack(with: [Tribe_2_1_0.self, Tribe_1_0_15.self, Tribe_0_0_1.self, Tribe_3_1_0.self]).migrate()
        
        wait(for: [willStartMigrationExpectation,
                   didMigrateToExpectation,
                   didFinishMigrationExpectation,
                   didInterruptMigrationExpectation], timeout: 5.0)
        
        let error = mockDelegate.error
        XCTAssertNil(error)
        
        let targets = mockDelegate.targets
        let expectedTargets: [TribeTarget] = [.literal("0.0.1"),
                                              .literal("1.0.15"),
                                              .literal("2.1.0"),
                                              .literal("3.1.0")]
        XCTAssertEqual(targets, expectedTargets)
    }
    
    func testTribeMigrationSkip() {
        let delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        
        let _ = Nomad.pack(with: [Tribe_2_1_0.self, Tribe_1_0_15.self, Tribe_0_0_1.self]).migrate()
        
        // Wait until first migration is complete
        wait(for: [delayExpectation], timeout: 5)
        
        let willStartMigrationExpectation = XCTestExpectation()
        let didMigrateToExpectation = XCTestExpectation()
        didMigrateToExpectation.expectedFulfillmentCount = 1
        let didFinishMigrationExpectation = XCTestExpectation()
        let didInterruptMigrationExpectation = XCTestExpectation()
        didInterruptMigrationExpectation.isInverted = true
        
        let mockDelegate = MockNomadDelegate(willStartMigrationExpectation,
                                             didMigrateToExpectation,
                                             didFinishMigrationExpectation,
                                             didInterruptMigrationExpectation)
        
        Nomad.set(delegate: mockDelegate)
        let _ = Nomad.pack(with: [Tribe_2_1_0.self, Tribe_1_0_15.self, Tribe_0_0_1.self, Tribe_3_1_0.self]).migrate()
        
        wait(for: [willStartMigrationExpectation,
                   didMigrateToExpectation,
                   didFinishMigrationExpectation,
                   didInterruptMigrationExpectation], timeout: 5.0)
        
        let error = mockDelegate.error
        XCTAssertNil(error)
        
        let targets = mockDelegate.targets
        let expectedTargets: [TribeTarget] = [.literal("3.1.0")]
        XCTAssertEqual(targets, expectedTargets)
    }
    
    func testThrowingTribeMigration() throws {
        let willStartMigrationExpectation = XCTestExpectation()
        let didMigrateToExpectation = XCTestExpectation()
        didMigrateToExpectation.expectedFulfillmentCount = 2
        let didFinishMigrationExpectation = XCTestExpectation()
        didFinishMigrationExpectation.isInverted = true
        let didInterruptMigrationExpectation = XCTestExpectation()
        
        let mockDelegate = MockNomadDelegate(willStartMigrationExpectation,
                                             didMigrateToExpectation,
                                             didFinishMigrationExpectation,
                                             didInterruptMigrationExpectation)
        
        Nomad.set(delegate: mockDelegate)
        let _ = Nomad.pack(with: [Tribe_2_1_0.self, Tribe_1_0_15.self, Tribe_Throws.self]).migrate()
        
        wait(for: [willStartMigrationExpectation,
                   didMigrateToExpectation,
                   didFinishMigrationExpectation,
                   didInterruptMigrationExpectation], timeout: 5.0)
        
        let error = try XCTUnwrap(mockDelegate.error)
        XCTAssertNotNil(error)
        
        let targets = mockDelegate.targets
        let expectedTargets: [TribeTarget] = [.literal("1.0.15"),
                                              .literal("2.1.0"),]
        XCTAssertEqual(targets, expectedTargets)
    }
    
    static var allTests = [
        ("testTribeMigration", testTribeMigration),
        ("testTribeMigrationSkip", testTribeMigrationSkip),
        ("testThrowingTribeMigration", testThrowingTribeMigration)
    ]
}
