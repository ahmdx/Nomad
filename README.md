# Nomad 🐪

Nomad allows you to create migration units, called Tribes, for each version of your app and takes care of executing them for you.

```swift
import Nomad
import PromiseKit

struct Tribe_2_0_0: Tribe {
  static let target: TribeTarget = .literal("2.0.0")
  
  func migrate() throws -> Promise<Void> {
    // Your migration logic for version 2.0.0
    ...
    
    return Promise()
  }
}
```

If your migration logic happens to be asynchronous, then

```swift
import Nomad
import PromiseKit

struct Tribe_2_0_0: Tribe {
  static let target: TribeTarget = .literal("2.0.0")
  
  func migrate() throws -> Promise<Void> {
    return Promise<Void> { seal in
      someAsyncMagic() { error in
        if (error != nil) {
          seal.reject(error)
        } else {
          seal.fulfill(())
        }
      }
    }
  }
}
```

# Requirements

- Swift 5+

# Installation

Nomad is currently only available through the Swift Package Manager.

```swift
.package(url: "https://github.com/ahmdx/Nomad", from: "0.9.0"),
```

# Why Nomad?

Nomad is created to solve a specific problem; simplifying updating the app's dependencies between app versions. If your app is required to perform some data changes, or operations, before the users can start using the new app version, Nomad can help you do that.

Let's say your app created multiple changes to the data store it uses that need to be strictly applied in order between versions 2.0.0, 2.5.0 and 3.0.0. Normally, you would need to manage that manually by keeping track of the last applied change and go ahead from there. You would need to make sure that users updating from version 1.0.0 to 3.0.0 not only have changes in 3.0.0 applied but also changes in 2.0.0 and 2.5.0. If some users are updating from 2.5.0 to 3.0.0, you would need to make sure that only changes in 3.0.0 are applied. Do you see how it can get so complicated so quickly? With Nomad, you would only need to create 3 tribes, one for each version, and Nomad will take care of executing these changes for you.

# Usage

Nomad takes a list of tribes, only their types, and orders them according to their specified targets. A `TribeTarget` is an `enum` that specifies the order in which each tribe is to be migrated in. `TribeTarget` defines three cases: `.first`, `.always` and `.literal(String)`. Nomad orders the tribes according to the following constraints:

- `.first` precedes all `.literal` and `.always` targets,
- `.literal` precedes other `.literal` targets according to their semVer values (e.g. `.literal("1.0.0")` < `.literal("2.0.0")`) and all other `.always` targets, and
-  `.always` succeeds all other targets.

> `.first` and `.always` are convenience targets. *Tribes with `.first` targets are migrated only once if at least one tribe with `.literal` target has been successfully migrated and committed. Otherwise, they are migrated every time Nomad carries a migration. Tribes with `.always` targets are always migrated at the end of a successful Nomad migration.

> Nomad uses a library called [Version](https://github.com/mxcl/Version) to order `.literal` targets.

## A Nomad Tribe

For Nomad to be able to perform the migration, it needs to know what to do and when to do it. A `Tribe` is a unit that holds such information and is defined as:

```swift
public protocol Tribe {
  static var target: TribeTarget { get }
  
  init()
  func migrate() throws -> Promise<Void>
}
```

## Packing the Tribes

Packing is the process of ordering the tribes supplied to Nomad for migration.

```swift
let packedNomad = Nomad.pack(with: [Tribe_1_1_0.self, Tribe_1_2_0.self, Tribe_First.self, Tribe_Always.self])
```

> `pack(with:)` can cause the app to crash if some of the tribes have illegal targets; `.literal` targets that are not semVer compliant. You need to make sure that all the tribes have legal targets. See [Auditing the Tribes](https://github.com/ahmdx/Nomad#auditing-the-tribes).

## Migrating the Tribes

After packing the tribes, they are now ready to migrate! The process of migration is as simple as calling a single method. *Since there might be a handful of tribes packed, tribes are only instantiated before they are migrated.*

```swift
Nomad.migrate()
```

`migrate()` returns a promise which will be resolved when either all tribes are migrated successfully or an error occurs. In that latter case, the migration process comes to a halt. *Nomad automatically catches errors thrown in `migrate` and informs the app about them.*

```swift
Nomad.migrate().done {
  // Handle migration success
}
.catch { error in
  // Handle migration error
}
```

Nomad also provides another way of notifying the app about the migration process using a delegate. Just make sure to set the delegate before migrating. *See `NomadDelegate.swift` for all the required methods.*

```swift
Nomad.set(delegate: self)
Nomad.migrate()
```

Nomad begins the next tribe migration in the sequence only after the current tribe migration resolves to allow for migration dependencies to be satisfied. After every successful tribe migration, the target of that tribe is stored locally which allows the migration to continue in the future from where it left off. You don't have to worry about a tribe being migrated more than once.

> Nomad uses a library called [PromiseKit](https://github.com/mxcl/PromiseKit) to provide promises support.

## Auditing the Tribes

Since packing the tribes can cause the app to crash, you may need to audit them to make sure Nomad can safely perform the migration.

```swift
Nomad.audit(tribes: [Tribe_1_1_0.self, Tribe_1_2_0.self, Tribe_First.self, Tribe_Always.self])
```

Calling `audit` will return an array of the tribes with illegal targets if there are any. It is recommended to include it in your test suite to ensure that no crashes happen in production.

# License
Nomad is created by [Ahmed Mohamed](https://github.com/ahmdx) and released under the Apache 2.0 license. See [LICENSE](https://github.com/ahmdx/Nomad/blob/main/LICENSE).
