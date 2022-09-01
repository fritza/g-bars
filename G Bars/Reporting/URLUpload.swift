//
//  URLUpload.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/1/22.
//

import Foundation

public enum UploadServerCreds {
    static let userID      = "iosuser"
    static let password    = "Daf4Df24fshfg"
    static let lastPassName = "ios-s3-apidev"

    static let methodName = "POST"

    static let uploadString    = "https://ios-s3-apidev.uchicago.edu/api/upload"
    static let uploadURL = URL(string: uploadString)!

    static let reviewPage = "https://ios-s3-apidev.uchicago.edu/files/"
    static let reviewURL = URL(fileURLWithPath: reviewPage)
}


public class SessionTaskDelegate: NSObject, URLSessionTaskDelegate {

    public typealias ChallengeCallback = (URLSession.AuthChallengeDisposition, URLCredential?)
    -> Void


    public func resultFunction(data: Data?, response: URLResponse?, error: Error?) {
        defer { semaphore.signal() }
        if let data = data {
            print("Data:", data)
            let dataString = String(data: data, encoding: .utf8)!
            print("\t\(dataString.prefix(512))")
        }
        else {
            print("Nil data")
        }

        if let httpResponse = response as? HTTPURLResponse {
            print(); print("Response: (\(httpResponse.statusCode))", HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
        }
        else {
            print(); print("No decodable response")
        }

        if let error = error {
            print(); print("Error:", error)
        }
        else {
            print(); print("No Error")
        }
    }


    public let credential = URLCredential(
        user: UploadServerCreds.userID,
        password: UploadServerCreds.password,
        persistence: .forSession)

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


public protocol UpParameters: Hashable, CustomStringConvertible {
    var key: String { get }
    var type: String { get }
    var contentType: String? { get }
    var disabled: Bool { get }

    mutating func setDisabled(to: Bool)
    mutating func setContentType(to: String?)
}

public struct FileParameters: Hashable, CustomStringConvertible {
    let key: String
    let src: String
    let type: String
    private(set) var contentType: String?
    private(set) var disabled = false

    public init(key: String, src: String, type: String = "file") {
        (self.key, self.src, self.type) = (key, src, type)
    }

    public var description: String {
        "FileParameters(key: \(key), type: \(type)) src: “\(src)”"
    }

    public mutating func setDisabled(to doDisable: Bool) {
        self.disabled = doDisable
    }

    public mutating func setContentType(to type: String?) {
        self.contentType = type
    }

    public var url: URL {
        URL(fileURLWithPath: src)
    }

    public var path: String {
        url.path
    }

    public func dataContent() throws -> Data {
        return try Data(contentsOf: self.url)
    }

    public func stringContent() throws -> String? {
        String(data: try self.dataContent(), encoding: .utf8)
    }
}

// FIXME: Take arbitrary paths/URLs, not just Bundle.main.

public class POSTCreator {
    let boundary = "Boundary-\(UUID().uuidString)"
    static let semaphore = DispatchSemaphore(value: 0)
    let parameters: [FileParameters]

    public init(for parameters: [FileParameters]) {
        self.parameters = parameters
    }

    public convenience init(atPath path: String, key: String) {
        let fileParams = FileParameters(key: key, src: path)
        self.init(for: [fileParams])
    }

    public convenience init(atURL url: URL, key: String) {
        let fileParams = FileParameters(key: key, src: url.path)
        self.init(for: [fileParams])
    }


    func addPartialBody(from fParameter: FileParameters,
                     into body: inout String) {
        assert(!fParameter.disabled,
               "Disabled FileParameters got into \(#function), line \(#line)")
        print(#function, "parameter loop", #line)
        let paramName = fParameter.key
        body += """
--\(boundary)\r
Content-Disposition:form-data; name="\(paramName)"
"""
        if let cType = fParameter.contentType {
            body += "\r\nContent-Type: \(cType)"
        }

        if fParameter.type == "text" {
            // FIXME: just a placeholder
            let value = fParameter.src
            body += "\r\n\r\n\(value)\r\n"
        }
        else if let fileContent = try! fParameter.stringContent() {
            body += "; filename=\"\(fParameter.src)\"\r\n"
            + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
        }
        else {
            preconditionFailure("Could not get string content from \(fParameter)")
        }
        print(#function, "end of iteration", #line)
    }

    func fullBody() throws -> Data {
        var body = ""
        for param in parameters where !param.disabled {
            addPartialBody(from: param, into: &body)
        }
        body += "--\(boundary)--\r\n";

        let postData = body.data(using: .utf8)
        assert(postData != nil,
               "Could not convert body to Data at \(#function)")
        return postData!
    }

    func formPostRequest(for postData: Data) -> URLRequest {
        var request = URLRequest(url: UploadServerCreds.uploadURL, timeoutInterval: Double.infinity)
        let kvp: KeyValuePairs = [
            //        "Authorization": "Basic aW9zdXNlcjpEYWY0RGYyNGZzaGZn",
            // if ever needed, use Basic base64(userID + ":" + password)
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
        for (hdr, value) in kvp {
            request.addValue(value, forHTTPHeaderField: hdr)
        }

        request.httpMethod = "POST"
        request.httpBody = postData
        return request
    }

    public func transmitAllFiles() throws {
        let bodyData : Data       = try fullBody()
        let request  : URLRequest = formPostRequest(for: bodyData)
        let task = URLSession.shared.dataTask(
            with: request,
            completionHandler: resultFunction)
        task.delegate = SessionTaskDelegate()
        task.resume()

        /*
         Naïve attempt at using uploadTask did not immediately work.

         let ulRequest = formUploadRequest()
         let ulTask = URLSession.shared.uploadTask(with: ulRequest, from: bodyData)
         ulTask.delegate = SessionTaskDelegate()
         ulTask.resume()
         */
    }
}

extension POSTCreator {
    public func resultFunction(data: Data?, response: URLResponse?, error: Error?) {
        defer {
            Self.semaphore.signal()
        }
        if let data = data {
            print("Data:", data)
            let dataString = String(data: data, encoding: .utf8)!
            print("\t\(dataString.prefix(512))")
        }
        else {
            print("Nil data")
        }

        if let httpResponse = response as? HTTPURLResponse {
            print(); print("Response: (\(httpResponse.statusCode))", HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
        }
        else {
            print(); print("No decodable response")
        }

        if let error = error {
            print(); print("Error:", error)
        }
        else {
            print(); print("No Error")
        }
    }
}
