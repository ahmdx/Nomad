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

import Foundation

/// Methods to notify a delegate about the migration lifecycle.
public protocol NomadDelegate: AnyObject {
    /// Called when the migration process is about to start.
    func willStartMigration()
    
    /// Called after each successful tribe migration.
    ///
    /// - Parameter target: The target of the successfully migrated tribe.
    func didMigrate(to target: TribeTarget)
    
    /// Called when all tribes have been successfully migrated.
    func didFinishMigration()
    
    /// Called when some of the tribes have failed to migrate.
    ///
    /// - Parameter error: A `NomadError` describing what caused the migration interruption.
    func didInterruptMigration(with error: NomadError)
}
