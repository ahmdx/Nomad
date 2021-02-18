import PromiseKit

/// Based on https://stackoverflow.com/a/60942269/2127376
/// Modified for better readability and to add `throws`.
extension Promise {
    /// Returns a single Promise that you can chain to. Wraps the chains of promises passed into the array into a serial promise to execute one after another using `promise1.then { promise2 }.then ...`
    ///
    /// - Parameter promisesToExecuteSerially: promises to stitch together with `.then` and execute serially
    /// - Returns: returns an array of results from all promises
    public static func chainSerially<T>(_ promises:[() throws -> Promise<T>]) -> Promise<[T]> {
        // Return a single promise that is fulfilled when
        // all passed promises in the array are fulfilled serially
        return Promise<[T]> { seal in
            var outResults = [T]()
            
            if promises.count == 0 {
                seal.fulfill(outResults)
                
                return
            }
            
            let finalPromise: Promise<T>? = try promises.reduce(nil) { (result, current) -> Promise<T> in
                guard let result = result else {
                    return try current()
                }
                
                return result.then { promiseResult -> Promise<T> in
                    outResults.append(promiseResult)
                    return try current()
                }
            }
            
            finalPromise?.done { result in
                outResults.append(result)
                
                seal.fulfill(outResults)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
