//
//  InterstitalPageTabView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI

struct InterstitalPageTabView: View {
    @State private var selectedPage: Int
    let listing: InterstitialList
    init(listing: InterstitialList, selection: Int) {
        self.listing = listing
        selectedPage = selection
    }

    var body: some View {
        VStack {
            TabView(selection: $selectedPage) {
                ForEach(listing) {
                    item in
                    VStack {
                        Text(item.intro)
                            .font(.caption)
                            .minimumScaleFactor(0.5).padding()
                        Image(systemName: item.systemImage ?? "circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.accentColor)
                            .frame(width: 200)
                            .symbolRenderingMode(.hierarchical)

                        Button(item.proceedTitle) {
                            // Do something with selectedPage.
                        }
                    }
                    .navigationTitle(item.pageTitle)
                }
            }.tabViewStyle(.page(indexDisplayMode: .never))
            Spacer()
        }
    }
}


struct InterstitalPageTabView_Previews: PreviewProvider {
    static let instruction_TEMP_list = InterstitialList(baseName: "walk-intro")

    static var previews: some View {
        InterstitalPageTabView()
    }
}



