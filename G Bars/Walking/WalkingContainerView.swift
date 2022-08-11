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
        case interstitial_1, countdown_1, walk_1
        case interstitial_2, countdown_2, walk_2
        case end_interstitial
    }

    @State var state: WalkingState? = .interstitial_1

    var body: some View {
        NavigationView {
            LazyVStack {
                // MARK: Intro
                NavigationLink(
                    "SHOULDN'T SEE (interstitial_1)"
                    , tag:


                        WalkingState.interstitial_1,


                    selection: $state

                ) {
                    InterstitalPageTabView(listing: instruction_TEMP_list, selection: 1) {

                        self.state = .countdown_1

                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
                }
                .hidden()

                // MARK: countdown (1)
                NavigationLink(
                    "SHOULDN'T SEE (countdown_1)", tag:


                        WalkingState.countdown_1,


                    selection: $state
                ) {
                    SweepSecondView(duration: 5.0) {

                        state = .walk_1

                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
                }
                .hidden()

                // MARK: Walk (1)
                NavigationLink(
                    "SHOULDN'T SEE (walk_1)", tag:


                        WalkingState.walk_1,


                    selection: $state
                ) {
                    DigitalTimerView(duration: countdown_TMP_Duration,
                                     immediately: true) {

                        // TODO: Should not rely on Next at end of walk to get here.
                        state = .interstitial_2

                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
                }
                .hidden()


                // MARK: Mid
                NavigationLink(
                    "SHOULDN'T SEE (interstitial_2)", tag:


                        WalkingState.interstitial_2,


                    selection: $state
                ) {
                    InterstitalPageTabView(listing: mid_instruction_TMP_list, selection: 1) {

                        self.state = .countdown_2

                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
                }
                .hidden()

                // MARK: Countdown (2)
                NavigationLink(
                    "SHOULDN'T SEE (countdown_2)", tag:


                        WalkingState.countdown_2,


                    selection: $state
                ) {
                    SweepSecondView(duration: 5.0) {

                        state = .walk_2

                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
                }
                .hidden()


                // MARK: Walking (2)
                NavigationLink(
                    "SHOULDN'T SEE (walk_2)", tag:


                        WalkingState.walk_2,


                               selection: $state
                ) {
                    DigitalTimerView(duration: 71.0) {

                        state = .end_interstitial

                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
                }
                .hidden()


                // MARK: End
                NavigationLink(
                    "SHOULDN'T SEE (end_interstitial)", tag:


                        WalkingState.end_interstitial,


                    selection: $state
                ) {
                    InterstitalPageTabView(listing: end_walking_List, selection: 1) {

                        self.state = .interstitial_1

                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
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
