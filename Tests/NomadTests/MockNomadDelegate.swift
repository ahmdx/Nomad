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

class MockNomadDelegate: NomadDelegate {
    let willStartMigrationExpectation: XCTestExpectation
    let didMigrateToExpectation: XCTestExpectation
    let didFinishMigrationExpectation: XCTestExpectation
    let didInterruptMigrationExpectation: XCTestExpectation
    
    var error: Error?
    var targets: [TribeTarget] = []
    
    init(_ willStartMigrationExpectation: XCTestExpectation,
         _ didMigrateToExpectation: XCTestExpectation,
         _ didFinishMigrationExpectation: XCTestExpectation,
         _ didInterruptMigrationExpectation: XCTestExpectation) {
        self.willStartMigrationExpectation = willStartMigrationExpectation
        self.didMigrateToExpectation = didMigrateToExpectation
        self.didFinishMigrationExpectation = didFinishMigrationExpectation
        self.didInterruptMigrationExpectation = didInterruptMigrationExpectation
    }
    
    func willStartMigration() {
        willStartMigrationExpectation.fulfill()
    }
    
    func didMigrate(to target: TribeTarget) {
        self.targets.append(target)
        didMigrateToExpectation.fulfill()
    }
    
    func didFinishMigration() {
        didFinishMigrationExpectation.fulfill()
    }
    
    func didInterruptMigration(with error: NomadError) {
        self.error = error
        didInterruptMigrationExpectation.fulfill()
    }
    
    
}
