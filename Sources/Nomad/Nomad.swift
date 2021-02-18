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
import PromiseKit
import Version

fileprivate typealias MigrationPromise = () throws -> Promise<Void>

/// A utility that simplifies the process of migrating apps between different versions.
public struct Nomad {
    /// Retrieves the target of the last successfully migrated tribe. If there is no target, or tribes with only `.first`
    ///  or `.always` targets have been migrated, `.first` is returned.
    public static var currentTarget: TribeTarget {
        guard let target = UserDefaults.standard.string(forKey: Constants.currentTarget.rawValue) else {
            return .first
        }
        
        return .literal(target)
    }
    
    fileprivate static var tribes: [Tribe.Type] = []
    fileprivate static weak var delegate: NomadDelegate?
    
    /// Sets the delegate used to notify about the migration life cycle.
    ///
    /// - note:
    /// Setting a delegate is optional.
    ///
    /// - Parameter delegate: The delegate to set.
    public static func set(delegate: NomadDelegate) {
        self.delegate = delegate
    }
    
    /// Sets and orders the tribes that should be migrated.
    ///
    /// Tribes are ordered by their targets, `TribeTarget`, as follows:
    /// * `.first` precedes all `.literal` and `.always` targets,
    /// * `.literal` precedes other `.literal` targets according to their semVer values (e.g. `.literal("1.0.0")` < `.literal("2.0.0")`)
    ///   and all other `.always` targets, and
    /// * `.always` succeeds all other targets.
    ///
    /// - attention:
    /// This method **must** be called before calling `Nomad.migrate() -> Promise`. Migrating without packing
    /// the tribes is the equivalent of not migrating at all.
    ///
    /// - warning:
    /// This method can cause the app to crash if some of the tribes have illegal targets.
    /// All tribes **must** have legal targets for the migration to proceed. To avoid crashing the app, use
    /// `Nomad.audit(tribes:) -> (Bool, Int)` to verify all tribes have legal targets. It is recommended to
    /// use `audit` it in your test suite.
    ///
    /// - Parameter tribes: The tribe types that should be migrated.
    /// - Returns: `Nomad` type.
    public static func pack(with tribes: [Tribe.Type]) -> Nomad.Type {
        self.tribes = tribes.sorted {
            try! ($0.target < $1.target)
        }
        
        return Nomad.self
    }
    
    /// Initiates the migration process.
    ///
    /// Before migration, the tribes are filtered to exclude tribes that have already been migrated, according to `Nomad.currentTarget`.
    /// If no tribe with a `.literal` target have ever been migrated before and the tribes include a `.first` target, the tribe with the
    /// `.first` target will be included in the migration. This ensures migrating to a `.first` target happens at least once.
    ///
    /// All tribes are migrated sequentially to ensure dependencies, if there are any, between tribes are satisfied. After each successful
    /// tribe migration, `Nomad.currentTarget` is updated to reflect the target of the recently migrated tribe. *The delegate is notified
    /// with the lifecycle of the migration process.*
    ///
    /// In case of interruptions due to errors, the migration process comes to a halt, the delegate is notified (optional) and
    /// the returned promise is rejected.
    ///
    /// - note:
    /// Tribes are instantiated only before they are being migrated.
    /// Tribes with `.always` targets are always included in the migration.
    ///
    /// - Returns: A promise that will resolve when the migration succeeds or fails with an error.
    public static func migrate() -> Promise<Void> {
        let tribesNotYetMigrated = notYetMigratedTribes()
        
        let migrationPromises: [MigrationPromise] = tribesNotYetMigrated.map({ tribeType in
            return {
                let target = tribeType.target
                let tribe = tribeType.init()
                
                return try tribe.migrate().then { _ -> Promise<Void> in
                    if case let .literal(targetValue) = target {
                        UserDefaults.standard.setValue(targetValue, forKey: Constants.currentTarget.rawValue)
                    }
                    
                    self.delegate?.didMigrate(to: target)
                    
                    return Promise()
                }
            }
        })
        
        self.delegate?.willStartMigration()
        
        return Promise<Void> { seal in
            Promise<Void>.chainSerially(migrationPromises).done { _ in
                self.delegate?.didFinishMigration()
                
                seal.fulfill(())
            }
            .ensure {
                UserDefaults.standard.synchronize()
            }
            .catch { error in
                let migrationError = NomadError.tribeMigrationFailed(error.localizedDescription)
                
                self.delegate?.didInterruptMigration(with: migrationError)
                
                seal.reject(migrationError)
            }
        }
    }
    
    /// Filters the tribe types according to `Nomad.currentTarget`.
    ///
    /// - Returns: The filtered tribe types.
    fileprivate static func notYetMigratedTribes() -> [Tribe.Type] {
        let currentTarget = self.currentTarget
        
        return self.tribes.filter { tribeType in
            let target = tribeType.target
            
            if case .literal = currentTarget, try! (target <= currentTarget) {
                return false
            }
            
            return true
        }
    }
}
