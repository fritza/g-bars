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

struct WalkingContainerView: View {
    @State var state: WalkingState? = .interstitial_1

    @State private var shouldShowActivity = false
    @State private var walkingData = Data()

    var body: some View {
        NavigationView {
            VStack {
                interstitial_1View()
                countdown_1View()
                walk_1View()
                interstitial_2View()
                countdown_2View()
                walk_2View()
                end_interstitialView()
            }   // VStack
        }       // NavigationView

        // MARK: Usability
        .navigationTitle("Walking (beta)")
    } // body
}

// MARK: - Walking stages
extension WalkingContainerView {
    @ViewBuilder
    func interstitial_1View() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (interstitial_1)",
            tag: WalkingState.interstitial_1, selection: $state) {
                InterstitalPageTabView(listing: instructionList, selection: 1) {
                    self.state = .countdown_1
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
    }

    @ViewBuilder
    func countdown_1View() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (interstitial_1)",
            tag: WalkingState.interstitial_1, selection: $state) {
                InterstitalPageTabView(listing: instructionList, selection: 1) {
                    self.state = .walk_1
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
    }

    @ViewBuilder
    func walk_1View() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (walk_1)",
            tag: WalkingState.walk_1, selection: $state) {
                DigitalTimerView(duration: countdown_TMP_Duration) {
                    // → .interstitial_2
                    state = .interstitial_2
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
        //                .hidden()
    }

    @ViewBuilder
    func interstitial_2View() -> some View    {             NavigationLink(
        "SHOULDN'T SEE (interstitial_2)",
        tag: WalkingState.interstitial_2, selection: $state) {
            InterstitalPageTabView(listing: mid_instructionList, selection: 1) {
                // → .countdown_2
                self.state = .countdown_2
            }.padding()
                .navigationBarBackButtonHidden(true)
        }
        //                .hidden()
    }

    @ViewBuilder
    func mid_instructionListView() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (interstitial_2)",
            tag: WalkingState.interstitial_2, selection: $state) {
                InterstitalPageTabView(listing: mid_instructionList, selection: 1) {
                    // → .countdown_2
                    self.state = .countdown_2
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
        //                .hidden()
    }

    @ViewBuilder
    func countdown_2View() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (countdown_2)",
            tag: WalkingState.countdown_2, selection: $state) {
                SweepSecondView(duration: sweep_TMP_Duration) {
                    // → .walk_2
                    state = .walk_2
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
        //                .hidden()
    }

    func walk_2View() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (walk_2)",
            tag: WalkingState.walk_2, selection: $state) {
                DigitalTimerView(duration: countdown_TMP_Duration) {
                    // → .end_interstitial
                    state = .end_interstitial
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
        //                .hidden()
    }

    @ViewBuilder
    func end_interstitialView() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (end_interstitial)",
            tag: WalkingState.end_interstitial, selection: $state) {
                InterstitalPageTabView(
                    listing: end_walkingList, selection: 1) {
                        self.state = .interstitial_1
                    }.padding() // completion closure for end_walkingList
                    .navigationBarBackButtonHidden(true)
            }
    }
}

// MARK: - Preview
struct WalkingContainerView_Previews: PreviewProvider {

    static var previews: some View {
        WalkingContainerView()
    }
}

/*      SHOW-ACTIVITY button
 Button {
 shouldShowActivity = true
 }
 label: { Label(
 "Tap to Export",
 systemImage: "square.and.arrow.up")
 }
 .buttonStyle(.bordered)
 */


/*

 }   // NavigationView
 .sheet(isPresented: $shouldShowActivity, content: {
 ActivityUIController(
 //                    data: walkingData,
 data: "01234 N/A 56789".data(using: .utf8)!,
 text: "01234 N/A 56789"
 //textEquivalent)
 )
 }) // .sheet content

 */
