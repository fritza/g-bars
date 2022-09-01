//
//  SessionTaskDelegate.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/1/22.
//

import Foundation

// MARK: - SessionTaskDelegate
public class SessionTaskDelegate: NSObject, URLSessionTaskDelegate {
    /// The wait-for-end-of-upoad semaphore, `static` from ``POSTCreator``.
    let semaphore: DispatchSemaphore
    init(semaphore: DispatchSemaphore) {
        self.semaphore = semaphore
    }

    /// Authorization callback method allowed in ``URLSessionTaskDelegate``
    public typealias ChallengeCallback = (URLSession.AuthChallengeDisposition, URLCredential?)
    -> Void

    /// Permanent credentials with the remote server's username and password for Basic authorization.
    public let credential = URLCredential(
        user: UploadServerCreds.userID,
        password: UploadServerCreds.password,
        persistence: .forSession)

    /// ``URLSessionTaskDelegate`` adoption for authorization challenges.
    public func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping ChallengeCallback) {
        print("Got challenge",
              challenge.protectionSpace.authenticationMethod)
        print("Challenge =", challenge)

        let method = challenge.protectionSpace.authenticationMethod
        guard method == NSURLAuthenticationMethodHTTPBasic else {
            print("Not basic")
            completionHandler(.performDefaultHandling, nil)
            return
        }
        completionHandler(.useCredential, credential)
    }
}
