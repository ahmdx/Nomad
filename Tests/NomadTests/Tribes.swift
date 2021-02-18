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

import PromiseKit
import Foundation
@testable import Nomad

struct Tribe_0_0_1: Tribe {
    static var target: TribeTarget = .literal("0.0.1")
    
    func migrate() -> Promise<Void> {
        return Promise()
    }
}

struct Tribe_1_0_15: Tribe {
    static var target: TribeTarget = .literal("1.0.15")
    
    func migrate() throws -> Promise<Void> {
        return Promise()
    }
}

struct Tribe_2_1_0: Tribe {
    static var target: TribeTarget = .literal("2.1.0")
    
    func migrate() throws -> Promise<Void> {
        return Promise()
    }
}

struct Tribe_3_1_0: Tribe {
    static var target: TribeTarget = .literal("3.1.0")
    
    func migrate() throws -> Promise<Void> {
        return Promise<Void> { seal in
            after(seconds: 2.0).done {
                seal.fulfill(())
            }
        }
    }
}

struct Tribe_First: Tribe {
    static var target: TribeTarget = .first
    
    func migrate() throws -> Promise<Void> {
        return Promise()
    }
}

struct Tribe_Always: Tribe {
    static var target: TribeTarget = .always
    
    func migrate() throws -> Promise<Void> {
        return Promise()
    }
}

struct Tribe_InvalidLiteral: Tribe {
    static var target: TribeTarget = .literal("XYZ")
    
    func migrate() throws -> Promise<Void> {
        return Promise()
    }
}

struct Tribe_NonCompliantSemVer: Tribe {
    static var target: TribeTarget = .literal("2.0")
    
    func migrate() throws -> Promise<Void> {
        return Promise()
    }
}

struct Tribe_Throws: Tribe {
    static var target: TribeTarget = .literal("3.0.0")
    func migrate() throws -> Promise<Void> {
        throw NSError(domain: "Failing Tribe", code: 0, userInfo: nil)
    }
}
