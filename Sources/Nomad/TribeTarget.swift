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

import Version

/// A type used to define the order in which the tribes are to be migrated.
public enum TribeTarget {
    case first
    case literal(_ target: String)
    case always
}

extension TribeTarget {
    /// Validates whether the target is a legal target.
    ///
    /// - Throws: An error if the target is illegal (i.e. not semVer compliant).
    public func validate() throws {
        switch self {
        case let .literal(target):
            guard let _ = Version(target) else {
                throw TargetError.semVerNonCompliant("Tribe targets must be SemVer compliant. \(target) is non-compliant.")
            }
        default:
            return
        }
    }
}

extension TribeTarget: Equatable {
    public static func ==(lhs: TribeTarget, rhs: TribeTarget) throws -> Bool {
        if case .first = lhs, case .first = rhs {
            return true
        }
        
        if case .always = lhs, case .always = rhs {
            return true
        }
        
        if case let .literal(firstTarget) = lhs, case let .literal(secondTarget) = rhs {
            guard let first = Version(firstTarget) else {
                throw TargetError.semVerNonCompliant("Tribe targets must be SemVer compliant. \(firstTarget) is non-compliant.")
            }
            
            guard let second = Version(secondTarget) else {
                throw TargetError.semVerNonCompliant("Tribe targets must be SemVer compliant. \(secondTarget) is non-compliant.")
            }
            
            return first == second
        }
        
        return false
    }
    
    public static func <(lhs: TribeTarget, rhs: TribeTarget) throws -> Bool {
        if case .first = lhs {
            return true
        }
        
        if case .literal = lhs, case .always = rhs {
            return true
        }
        
        if case let .literal(firstTarget) = lhs, case let .literal(secondTarget) = rhs {
            guard let first = Version(firstTarget) else {
                throw TargetError.semVerNonCompliant("Tribe targets must be SemVer compliant. \(firstTarget) is non-compliant.")
            }
            
            guard let second = Version(secondTarget) else {
                throw TargetError.semVerNonCompliant("Tribe targets must be SemVer compliant. \(secondTarget) is non-compliant.")
            }
            
            return first < second
        }
        
        return false
    }
    
    public static func <=(lhs: TribeTarget, rhs: TribeTarget) throws -> Bool {
        return try (lhs < rhs || lhs == rhs)
    }
}

extension TribeTarget: CustomStringConvertible {
    public var description: String {
        switch self {
        case .first:
            return "first"
        case .always:
            return "always"
        case let .literal(target):
            return "literal: \(target)"
        }
    }
}
