//
//  UploadFileParameters.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/1/22.
//

import Foundation

// MARK: - FileParameters
/// `struct` realization of the snippet’s notion of an upload that has a "source" string and contains `Data` (was `[[String:Any]]`).
///
/// In practice, `src` is always a fully-qualified pathname for a container file.
/// - warning: ``PostCreator`` assumes the contents can be decoded as UTF-8 text. **This is not necessarily so.** Provision for binary content will have to be added.
public struct UploadFileParameters: Hashable, CustomStringConvertible {
    /// Used to specify the `Content-Disposition` `name`.
    ///
    /// What the effect is difficult to determine. The upload process ends up at the remote with the last component of the path/URL.
    let key: String
    /// In practice, a `String` path to the file containing the data to send.
    ///
    /// The code ATW assumes the content is `String`. **Severe** limitation, but not immediately important.
    let src: String

    /// The `Content-Type` to be specified in the header. Defaults to `"file"`)
    let type: String

    /// `Content-Type`, as set in the initializer.
    ///
    /// To alter the value, use ``setContentType(to:)``
    private(set) var contentType: String?
    /// Whether this parameter (in an `Array`, for instance) should be omitted from the request. Default `false`.
    ///
    /// To alter the value, use ``setDisabled(to:)``
    private(set) var disabled = false

    /// Initialize by filling in the `let` properties. `type` defaults to `"file"`.
    public init(key: String, src: String, type: String = "file") {
        (self.key, self.src, self.type) = (key, src, type)
    }

    /// `CustomStringConvertible` adoption.
    public var description: String {
        "FileParameters(key: \(key), type: \(type)) src: “\(src)”"
    }

    /// Set  whether this file should be omitted from the request. The value itself is `false` by default.
    public mutating func setDisabled(to doDisable: Bool) {
        self.disabled = doDisable
    }

    /// Set the `Content-Type` for the request. The value itself is `"file"` by default.
    public mutating func setContentType(to type: String?) {
        self.contentType = type
    }

    /// The file path (`src`) rendered as a `file:///` URL. The URL is not guaranteed to point to an existing file.
    ///
    /// ``POSTCreator`` accepts `url`, _not_ the `src` file path as the truth of the location.
    public var url: URL { URL(fileURLWithPath: src) }

    /// The filesystem path at which to look for the upload content, based on `.url`, not the `src` path at initialization.
    public var path: String { url.path }

    /// The `Data` content of the file at this `.url`.
    /// - throws: Errors thrown by the `Data` initializer.
    public func dataContent() throws -> Data {
        try Data(contentsOf: self.url)
    }

    /// The `String` content of the file at this `.url`.
    /// - returns: The `String` decoded from the file's `Data`, or `nil` if it could not be decoded as UTF-8.
    /// - throws: Errors thrown by the `Data` initializer.
    public func stringContent() throws -> String? {
        String(data: try self.dataContent(), encoding: .utf8)
    }
}
