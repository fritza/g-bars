//
//  WalkingContainerView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI

private struct ContainedView: View {
    let systemName: String
    let text: String
    let closeout: () -> Void

    internal init(imageName: String, text: String, closeout: @escaping () -> Void) {
        self.systemName = imageName
        self.text = text
        self.closeout = closeout
    }

    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: self.systemName)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .foregroundColor(.accentColor)
                .symbolRenderingMode(.hierarchical)

            Text(self.text)
            Button("Continue", action: closeout)
        }
    }
}

struct WalkingContainerView: View {
    enum WalkingState: String, Hashable, CaseIterable {
        case interstitial_1, walk_1
        case interstitial_2, walk_2
        case end_interstitial
    }

    @State var state: WalkingState? = .interstitial_1

    var body: some View {
        NavigationView {
            VStack {
                // MARK: Intro interstitial
                NavigationLink(
                    "one??"
                    , tag: WalkingState.interstitial_1, selection: $state
                ) {
                    InterstitalPageTabView(listing: instruction_TEMP_list, selection: 1) {
                        self.state = .walk_1
                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
                }
                .hidden()

                // MARK: Walking (1)
                NavigationLink("two??", tag: WalkingState.walk_1,
                               selection: $state
                ) {
                    DigitalTimerView(duration: 71.0) {
                        state = .end_interstitial
                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
                }
                .hidden()

                // MARK: --
                NavigationLink("three?",
                               tag: WalkingState.end_interstitial,
                               selection: $state
                ) {
                    ContainedView(imageName: "arrow.triangle.capsulepath",
                                  text: "No progress.") {
                        self.state = .interstitial_1
                    }
                }
                .hidden()
            }

        }
    }
}

struct WalkingContainerView_Previews: PreviewProvider {

    static var previews: some View {
        WalkingContainerView()
    }
}
