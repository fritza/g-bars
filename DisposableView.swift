//
//  DisposableView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/26/22.
//

import SwiftUI
import UIKit.UIFont

// .←

struct DisposableView: View {
    struct ViewEdge: OptionSet
    {
        let rawValue: Int
        init(rawValue: Int) { self.rawValue = rawValue }

        static let left = ViewEdge(rawValue: 1)
        static let right = ViewEdge(rawValue: 2)
        static let both: ViewEdge = [.left, .right]
        static let neither: ViewEdge = []
    }

//    let edges: ViewEdge
    let completion: (ViewEdge) -> Void
    let leftLabel: String?
    let rightLabel: String?

    init(title: String,
         leftButtonName: String? = nil,
         rightButtonName: String? = nil,
         completion: @escaping (ViewEdge) -> Void) {
        self.completion = completion
        self.titleText = title

        leftLabel = leftButtonName
        rightLabel = rightButtonName
    }

    let titleText: String
    var titleFont: Font {
        Font.system(size: 20, weight: .bold, design: .rounded)
    }

    var titleFont2: Font {
        Font.custom("SFTitle", size: 30, relativeTo: .title)
    }

    static let buttonFont: Font = .title3

    func buttonWidth(within size: CGSize) -> CGFloat {
        Swift.max(32.0, size.width/5.0)
    }
// Daf4Df24fshfg
    // iosuser
    // name: ios-s3-apidev
    // URL: https://ios-s3-apidev.uchicago.edu/api/
    var body: some View {
        GeometryReader { proxy in
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    if let left = leftLabel {
                        Button(left, action: {
                            completion(.left)
                        })
                        .font(Self.buttonFont)
                        .frame(width: buttonWidth(within: proxy.size))
                    }
                    else {
                        Color.clear
                            .frame(width: buttonWidth(within: proxy.size))
                    }
                    Spacer()
                    Text("Title goes here.\n... and more")
                        .font(.title)
                        .fontWeight(.semibold)
                        .lineLimit(3)

                    Spacer()
                    if let right = rightLabel {
                        Button(right) {
                            completion(.right)
                        }
                        .font(Self.buttonFont)
                        .frame(width: buttonWidth(within: proxy.size))
                    }
                    else {
                        Color.clear
                            .frame(width: buttonWidth(within: proxy.size))
                    }
                }
            }
        }
    }
}

struct DisposableView_Previews: PreviewProvider {
    static let title = "Short title"
    static var previews: some View {
        DisposableView(title: "long, long title, how to fit?",
                       leftButtonName: "< Back", rightButtonName: "Next >") {
            choice in
            print((choice == .left) ? "left" : "right")
        }
                       .padding()
                       .previewDevice(
                        PreviewDevice(rawValue: "iPhone 4s")
                       )
    }
}
