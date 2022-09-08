//
//  UploadWalkSession.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/1/22.
//

import Foundation


// MARK: - UploadServerCreds
public enum UploadServerCreds {

    static let methodName = "POST"

#if API_DEV
    // Use for internal test and development
    static let lastPassName = "ios-s3-apidev"
    static let uploadString = "https://ios-s3-apidev.uchicago.edu/api/upload"
    static let userID       = "iosuser"
    static let password     = "Daf4Df24fshfg"
#elseif BETA_API
    // Use for TestFlight
    static let lastPassName = "ios-s3-apistage"
    static let uploadString = "https://ios-s3-apistage.uchicago.edu/api/upload"
    static let userID       = "iosuser"
    static let password     = "Daf4Df24fshfg"
#else
    // Public-release (production server)
    static let lastPassName = "ios-s3-api.uchicago.edu (PROD)"
    static let uploadString = "https://ios-s3-api.uchicago.edu/api/upload"
    static let userID       = "iosuser"
    static let password     = "#jd89DFa882%"
#endif
    static let uploadURL    = URL(string: uploadString)!

    static let reviewPage   = "https://ios-s3-apidev.uchicago.edu/files/"
    static let reviewURL    = URL(fileURLWithPath: reviewPage)
}

// MARK: - UploadWalkSession
public class UploadWalkSession {
    let session = URLSession.shared
//    let dataTask: URLSessionDataTask
    let dataRequest: URLRequest
    let dataURL: URL

    // let uploadPayload: Data
    // Is this needed beyond init(payload:)?

    init(from url: URL) throws {
        dataURL = url
        let payload = try Data(contentsOf: url)
        if payload.isEmpty {
            throw FileStorageErrors.uploadEmptyData(url.path)
        }

        var request = URLRequest(
            url: UploadServerCreds.uploadURL,
            timeoutInterval: TimeInterval.infinity)
        request.httpMethod = UploadServerCreds.methodName
        request.httpBody = payload
        dataRequest = request
    }

    func proceed() {
        let task = session.dataTask(
            with: UploadServerCreds.uploadURL, completionHandler: resultFunction)
        task.delegate = UploadTaskDelegate()
        task.resume()
    }

    fileprivate func resultFunction(data: Data?,
                                    response: URLResponse?,
                                    error: Error?) {
        // Any error means not deleting the .zip file.
        // ON RETRY: We have a sync problem.
        guard
            let response = response as? HTTPURLResponse,
            !(200..<300).contains(response.statusCode)
        else {
            print("Upload request failed: \(error!.localizedDescription)")
            // throw not allowed
            return
        }

        // By here, the source file is away. Delete it.
        do {
            try FileManager.default
                .deleteIfPresent(dataURL)
        }
        catch {
            print("Can't delete", dataURL.path, "error =", error.localizedDescription)
            return
        }
    }
}



// MARK: - SessionTaskUploadWalkSession Task dUploadWalkSessionile-upload transactions.
///
/// ATW, the only function is to carrry out the client side of credential exchange via ``urlSession(_:task:didReceive:completionHandler:)``
/// - todo: Use a dedicated `URLSession`.
public class UploadTaskDelegate: NSObject, URLSessionTaskDelegate {

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
