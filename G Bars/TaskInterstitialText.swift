//
//  TaskInterstitialText.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/9/22.
//

import Foundation

struct TaskInterstitialText: Codable, Hashable, Identifiable {
    let id: Int
    let intro: String
    let proceedTitle: String
    let systemImage: String?

    internal init(id: Int, intro: String, proceedTitle: String, systemImage: String?) {
        self.id = id
        self.intro = intro
        self.proceedTitle = proceedTitle
        self.systemImage = systemImage
    }

    internal init(_ stub: TaskInterstitialDecodable,
                  id: Int) {
        self.init(id: id,
                  intro: stub.intro,
                  proceedTitle: stub.proceedTitle,
                  systemImage: stub.systemImage)
    }
}

struct TaskInterstitialDecodable: Codable {
    let intro: String
    let proceedTitle: String
    let systemImage: String?
}

struct TaskInterstitialList: Codable {
    typealias Element = TaskInterstitialText
    typealias Index   = Int

    // Coding
    enum CodingKeys: String, CodingKey {
        case baseName, interstitials
    }
    static let decoder = JSONDecoder()


    let baseName: String
    let interstitials: [TaskInterstitialText]

    /// The `TaskInterstitialText`, if any, having the supplied ID.
    /// - note: This is an _ID,_ not the collection index used for subscripting.
    /// - parameter target: The ID to search for.
    /// - returns: `TaskInterstitialText` for the element with that ID, or `nil` if there is none.
    func item(forID target: Int) -> TaskInterstitialText? {
        let retval = interstitials
            .first(where: { $0.id == target } )
        return retval
    }

    /// Load the list of `TaskInterstitialText` from a (base)named `Bundle` file.
    ///
    /// Elements in the file will not specify IDs; they identify by their order in the `json` file. This initializer assigns each an `id`  of file order + 1.
    /// - Parameter baseName: The base name of the file to decode, e.g. `mumble` for `mumble.json`.  The source file must have the `json` extension.
    init(baseName: String) {
        self.baseName = baseName
        // Fill in the interstital list, if any
        if let url = Bundle.main.url(forResource: baseName, withExtension: "json"),
           let jsonData = try? Data(contentsOf: url),
           let rawList = try? Self.decoder
            .decode([TaskInterstitialDecodable].self,
                    from: jsonData) {
            let idedList = rawList.enumerated()
                .map { (idNum, content) in
                    return TaskInterstitialText(content, id: idNum+1)
                }
            interstitials = idedList
        }
        else {
            interstitials = []
        }
    }
}

// - MARK: RandomAccessCollection adoption
extension TaskInterstitialList: RandomAccessCollection {
    var startIndex: Int { 0 }
    var endIndex: Int { interstitials.count }
    subscript(index: Int) -> Element { interstitials[index] }
}
