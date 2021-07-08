//
//  NetworkResponseResult.swift
//  Cinema
//
//  Created by g.b.rastogi on 08/07/2021.
//

import Foundation
typealias NRResult<T> = Result<T, NetworkError>
typealias NRResultCompletion<T> = ((NRResult<T>) -> Void)
// MARK: - Internal APIs

extension NRResult {
    /// Returns the associated value if the result is a success, `nil` otherwise.
    var success: Success? {
        guard case .success(let value) = self else { return nil }
        return value
    }
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    var failure: Failure? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
    /// Initializes an `PNResult` from value or error. Returns `.failure` if the error is non-nil, `.success` otherwise.
    ///
    /// - Parameters:
    ///   - value: A value.
    ///   - error: An `Error`.
    init(value: Success, error: Failure?) {
        if let error = error {
            self = .failure(error)
        } else {
            self = .success(value)
        }
    }
}
