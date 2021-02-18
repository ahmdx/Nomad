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

extension Nomad {
    /// Ensures the validity of the passed tribe types.
    ///
    /// - Parameter tribes: The tribe types to audit.
    /// - Returns: An array containing the invalid tribe types if there are any.
    public static func audit(tribes: [Tribe.Type]) -> [Tribe.Type] {
        var invalidTribes: [Tribe.Type] = []
        
        tribes.forEach({ tribe in
            let target = tribe.target
            
            do {
                try target.validate()
            } catch TargetError.semVerNonCompliant(_) {
                invalidTribes.append(tribe)
            } catch _ {
                invalidTribes.append(tribe)
            }
        })
        
        return invalidTribes
    }
}
