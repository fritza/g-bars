//
//  InterstitialPageView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI

// MARK: - InterstitialPageView
/// A `View` that presents a single page derived from ``InterstitialInfo``:  text, SF Symbols name, Action button; plus a callback when the action button is tapped.
struct InterstitialPageView: View {
    let item: InterstitialInfo
    let proceedCallback: () -> Void

    /// Initialize the view given the content information and a button-action closure
    /// - Parameters:
    ///   - info: An ``InterstitialInfo`` specifying text and symbol content.
    ///   - callback: A closure to be called when the action button (**Next**, **Continue**, etc.) is tapped.
    init(info: InterstitialInfo,
         proceedCallback callback: @escaping () -> Void) {
        item = info
        self.proceedCallback = callback
    }

    // MARK: - body
    var body: some View {
        VStack {
            // MARK: Instructional text
            Text(item.intro)
                .font(.body)
                .minimumScaleFactor(0.75)
            Spacer(minLength: 30)
            // MARK: SF Symbol
            Image(systemName: item.systemImage ?? "circle")
                .resizable()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .frame(height: 200)
                .symbolRenderingMode(.hierarchical)
            Spacer()
            // MARK: Disclaimer
            // FIXME: Remove once the issues are resolved.
            Text("Button navigation not complete. swipe across the screen to change the page.\n\nThe size and layout of the instructions need work.").font(.caption).minimumScaleFactor(0.5).foregroundColor(.red)
            // MARK: The action button
            Button(item.proceedTitle, action: proceedCallback)
        }
        .navigationTitle(item.pageTitle)
    }
}

// MARK: - Preview
struct InterstitialPageView_Previews: PreviewProvider {
    static let sampleIInfo = InterstitialInfo(id: 3, intro: "This is the instructional text.\n\nIt may be very long.", proceedTitle: "Continue", pageTitle: "Exercise", systemImage: "figure.walk")

    static var previews: some View {
        NavigationView {
        InterstitialPageView(
            info: sampleIInfo,
        proceedCallback: { print("beep") })
        .padding()
        }
    }
}
