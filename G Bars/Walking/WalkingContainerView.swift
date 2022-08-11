//
//  WalkingContainerView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI


private let instructionList     = InterstitialList(baseName: "walk-intro"       )
private let mid_instructionList = InterstitialList(baseName: "second-walk-intro")
private let end_walkingList     = InterstitialList(baseName: "usability-intro"  )


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

enum WalkingState: String, Hashable, CaseIterable {
    case interstitial_1, countdown_1, walk_1
    case interstitial_2, countdown_2, walk_2
    case end_interstitial
}

struct WalkingContainerView: View {
    @State var state: WalkingState? = .interstitial_1

    var body: some View {
        NavigationView {
            // LazyVStack did not prevent double-initialization of the target views (and thereby creation of multiple timers, some of which expire (second walk) while the first walk is run.
            // Removing VStack didn't display countdown_1 when the intro was completed: nav title appeared, content did not.
            // removing .hidden() from interstitial_1 and countdown_1 cases had no effect (maybe fewer initailizations?)

            // Okay: Making sure all of these wait at least until onAppear before
            // they start counting fixed the multiple concurrent timers.
            // TODO: Prevent creation of redundant timers.

            VStack {
                // MARK: Intro
                NavigationLink(
                    "SHOULDN'T SEE (interstitial_1)",
                    tag: WalkingState.interstitial_1, selection: $state) {
                    InterstitalPageTabView(listing: instructionList, selection: 1) {
                        self.state = .countdown_1
                    }.padding()
                    .navigationBarBackButtonHidden(true)
                }

                // MARK: countdown (1)
                NavigationLink(
                    "SHOULDN'T SEE (countdown_1)",
                    tag: WalkingState.countdown_1, selection: $state) {
                    SweepSecondView(duration: 5.0) {
                        state = .walk_1
                    }.padding()
                    .navigationBarBackButtonHidden(true)
                }
//                .hidden()

                // MARK: Walk (1)
                NavigationLink(
                    "SHOULDN'T SEE (walk_1)",
                    tag: WalkingState.walk_1, selection: $state) {
                    DigitalTimerView(duration: countdown_TMP_Duration) {
                        state = .interstitial_2
                    }.padding()
                    .navigationBarBackButtonHidden(true)
                }
//                .hidden()


                // MARK: Mid
                NavigationLink(
                    "SHOULDN'T SEE (interstitial_2)",
                    tag: WalkingState.interstitial_2, selection: $state) {
                        InterstitalPageTabView(listing: mid_instructionList, selection: 1) {
                            self.state = .countdown_2
                        }.padding()
                    .navigationBarBackButtonHidden(true)
                }
                //                .hidden()

                // MARK: Countdown (2)
                NavigationLink(
                    "SHOULDN'T SEE (countdown_2)",
                    tag: WalkingState.countdown_2, selection: $state) {
                        SweepSecondView(duration: 5.0) {
                            state = .walk_2
                        }.padding()
                        .navigationBarBackButtonHidden(true)
                    }
                //                .hidden()


                // MARK: Walking (2)
                NavigationLink(
                    "SHOULDN'T SEE (walk_2)",
                    tag: WalkingState.walk_2, selection: $state) {
                        DigitalTimerView(duration: 71.0) {
                            state = .end_interstitial
                        }.padding()
                        .navigationBarBackButtonHidden(true)
                    }
                //                .hidden()


                // MARK: End
                NavigationLink(
                    "SHOULDN'T SEE (end_interstitial)",
                    tag: WalkingState.end_interstitial, selection: $state) {
                        InterstitalPageTabView(
                            listing: end_walkingList,
                            selection: 1) {
                                self.state = .interstitial_1
                            }.padding()
                            .navigationBarBackButtonHidden(true)
                    }
                //                .hidden()

                // MARK: Usability
                
            }
        }
    }
}

struct WalkingContainerView_Previews: PreviewProvider {

    static var previews: some View {
        WalkingContainerView()
    }
}
