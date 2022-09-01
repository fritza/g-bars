//
//  POSTCreator.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/1/22.
//

import Foundation

// MARK: - UploadServerCreds
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

/*
 The thought had been to realize the combination of text and file upload parameters rather than the snippet's making it an array of Any.
 Abandoned as unnecessary, String uploads aren't done in this app.

public protocol UpParameters: Hashable, CustomStringConvertible {
    var key: String { get }
    var type: String { get }
    var contentType: String? { get }
    var disabled: Bool { get }

    mutating func setDisabled(to: Bool)
    mutating func setContentType(to: String?)
}
 */


// FIXME: Take arbitrary paths/URLs, not just Bundle.main.

// MARK: - POSTCreator

/// Accepts (`String`) content from a file and uploads it.
///
///Typical usage is
/// ```
/// let creator = PostCreator(atPath: "/usr/var/tmp.str",
///                           key: "data/string")
/// try creator.transmitAllFiles()
/// ```
///
/// - warning: ``PostCreator`` assumes the contents can be decoded as UTF-8 text. **This is not necessarily so.** Provision for binary content will have to be added.

public class POSTCreator {
    /// Boundary line for the multipart submission. Includes a once-only `UUID`.
    let boundary = "Boundary-\(UUID().uuidString)"
    /// A semaphore to stall further upload attempts until the current one is finished.
    static let semaphore = DispatchSemaphore(value: 0)

    /// Descriptions of the files to be uploaded. Having more than one is not anticipated.
    let parameters: [UploadFileParameters]

    /// Initialize with an array of upload files.
    public init(for parameters: [UploadFileParameters]) {
        self.parameters = parameters
    }

    /// Initialize with a path to a single upload file.
    public convenience init(atPath path: String, key: String) {
        let fileParams = UploadFileParameters(key: key, src: path)
        self.init(for: [fileParams])
    }

    /// Initialize with a URL for a single upload file.
    public convenience init(atURL url: URL, key: String) {
        let fileParams = UploadFileParameters(key: key, src: url.path)
        self.init(for: [fileParams])
    }


    /// Add the content of a file to the body of the `POST` request
    /// - Parameters:
    ///   - fParameter: `FileParameters` specifying a single file.
    ///   - body: The `String` this part of the request is to be appended to.
    private func addPartialBody(from fParameter: UploadFileParameters,
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
            assertionFailure("\(#function), line \(#line) - unanticipated specification of `String` content.")
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

    /// The full _content_ of the upload request `FileParameter`s.
    private func fullBody() -> Data {
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

    /// Build a `URLRequest` for uploading some `Data`.
    /// - Parameter postData: the `Data` to be uploaded
    /// - Returns: The complete `URLRequest`.
    private func formPostRequest(for postData: Data) -> URLRequest {
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

    /// Execute a data task for uploading all the contents of the  `[FileParameters]` presented to the initializer.
    public func transmitAllFiles() throws {
        let bodyData : Data       = fullBody()
        let request  : URLRequest = formPostRequest(for: bodyData)
        let task = URLSession.shared.dataTask(
            with: request,
            completionHandler: resultFunction)
        task.delegate = SessionTaskDelegate(semaphore: Self.semaphore)
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
    fileprivate func resultFunction(data: Data?, response: URLResponse?, error: Error?) {
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
