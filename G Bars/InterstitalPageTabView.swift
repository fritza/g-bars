//
//  InterstitalPageTabView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI

struct InterstitalPageTabView: View {
    @State private var showEndOfList = false

    @State private var selectedPage: Int
    let listing: InterstitialList
    init(listing: InterstitialList, selection: Int) {
        self.listing = listing
        selectedPage = selection
    }

    var body: some View {
        TabView(selection: $selectedPage) {
            ForEach(listing) {
                item in
                InterstitialPageView(info: item) {
                    if item.id < listing.count {
                        selectedPage += 1
                    }
                    else {
                        showEndOfList = true
                    }
                }
            }
            .animation(.easeInOut,
                       value: selectedPage)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .alert("End of Instructions",
               isPresented: $showEndOfList) {}
    message: {
        Text("There are no further instructions, and the walk sequence that follows “Start” hasn't been completed.")
    }
    }
}


struct InterstitalPageTabView_Previews: PreviewProvider {
//    static let instruction_TEMP_list = InterstitialList(baseName: "walk-intro")

    static var previews: some View {
        NavigationView {
            InterstitalPageTabView(listing: instruction_TEMP_list, selection: 1)
                .padding()
        }
    }
}



