//
//  SessionTaskDelegate.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/1/22.
//

import Foundation

// MARK: - SessionTaskDelegate

/// Task delegate for file-upload transactions.
///
/// ATW, the only function is to carrry out the client side of credential exchange via ``urlSession(_:task:didReceive:completionHandler:)``
/// - todo: Use a dedicated `URLSession`.
public class SessionTaskDelegate: NSObject, URLSessionTaskDelegate {
    /// The wait-for-end-of-upoad semaphore.
    ///
    /// The value is expected to be the `static` semaphore  from ``POSTCreator``.
    let semaphore: DispatchSemaphore
    init(semaphore: DispatchSemaphore) {
        self.semaphore = semaphore
    }

    /// Shorthand for the callback method for receiving an authentication challenge.
    public typealias ChallengeCallback = (URLSession.AuthChallengeDisposition,
                                          URLCredential?) -> Void

    /// Permanent, re-usable credentials with the client-to-remote username and password for Basic authorization.
    public let credential = URLCredential(
        user        : UploadServerCreds.userID,
        password    : UploadServerCreds.password,
        persistence : .forSession)

    /// ``URLSessionTaskDelegate`` adoption for authorization challenges.
    public func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping ChallengeCallback) {
        let method = challenge.protectionSpace.authenticationMethod
        // Is the server asking for Basic authentication?
        guard method == NSURLAuthenticationMethodHTTPBasic else {
            // … no, pass it along to whomever might be interested
            completionHandler(.performDefaultHandling, nil)
            return
        }
        // … yes, use `self.credential` to supply username and password.
        completionHandler(.useCredential, credential)
    }
}
