//
//  InterstitialPageView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI

struct InterstitialPageView: View {
    let item: InterstitialInfo
    let proceedCallback: () -> Void

    init(info: InterstitialInfo,
         proceedCallback callback: @escaping () -> Void) {
        item = info
        self.proceedCallback = callback
    }

    var body: some View {
        VStack {
            Text(item.intro)
                .font(.body)
                .minimumScaleFactor(0.75).padding()
            Image(systemName: item.systemImage ?? "circle")
                .resizable()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .frame(width: 180)
                .symbolRenderingMode(.hierarchical)
            Spacer()
            Text("Button navigation not complete. swipe across the screen to change the page.\n\nThe size and layout of the instructions need work.").font(.caption).minimumScaleFactor(0.5).foregroundColor(.red)
            Button(item.proceedTitle, action: proceedCallback)
//            Button(item.proceedTitle) {
//                // Do something with selectedPage.
//            }
        }
        .navigationTitle(item.pageTitle)
    }
}

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
