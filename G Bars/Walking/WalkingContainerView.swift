//
//  WalkingContainerView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI
import UniformTypeIdentifiers


private let instructionContentList     = InterstitialList(baseName: "walk-intro"       )
private let mid_instructionContentList = InterstitialList(baseName: "second-walk-intro")
private let end_walkingContentList     = InterstitialList(baseName: "usability-intro"  )

let csvUTT       = UTType.commaSeparatedText
let csvUTTString = "public.comma-separated-values-text"

/// A wrapper view that programmatically displays stages of the walk test.
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
                ending_interstitialView()

// demo_summaryView()


            }   // VStack
        }       // NavigationView

        // MARK: Usability
        .navigationTitle("Walking (beta)")
    } // body
}

// MARK: - Walking stages
extension WalkingContainerView {
    /// A `NavigationLink` for initial instructions (`interstitial_1`)
    @ViewBuilder
    func interstitial_1View() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (interstitial_1)",
            tag: WalkingState.interstitial_1, selection: $state) {
                InterstitalPageContainerView(listing: instructionContentList, selection: 1) {
                    self.state = .countdown_1
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
    }

    /// A `NavigationLink` for the first pre-walk countdown (`countdown_1`)
    @ViewBuilder
    func countdown_1View() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (countdown_1)",
            tag: WalkingState.countdown_1, selection: $state) {
                InterstitalPageContainerView(listing: instructionContentList, selection: 1) {
                    self.state = .walk_1
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
    }

    /// A `NavigationLink` for the first timed walk (`walk_1`)
    @ViewBuilder
    func walk_1View() -> some View {
        // 1: Start the observer collecting.
        // 2: in the completion closure harvest the contents of the observer. Maybe save them out, though Dan may not be happy to see separate files for the two runs.
        // 3: There will be two of these.
        // Who owns the consumer?
        // because it looks like the only place to start
        // one is from inside DigitalTimerView.
        // That can be returned through the completion handler.

        // AND: The TimerView has to know something about the stage/prefix/data retrieval

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

    /// A `NavigationLink` for the interstitial view between the two walk sequences (`interstitial_2`)
    @ViewBuilder
    func interstitial_2View() -> some View    {             NavigationLink(
        "SHOULDN'T SEE (interstitial_2)",
        tag: WalkingState.interstitial_2, selection: $state) {
            InterstitalPageContainerView(listing: mid_instructionContentList, selection: 1) {
                // → .countdown_2
                self.state = .countdown_2
            }.padding()
                .navigationBarBackButtonHidden(true)
        }
        //                .hidden()
    }
    
    /// A `NavigationLink` for the second pre-walk countdown (`countdown_2`)
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

    /// A `NavigationLink` for the second timed walk (`walk_2`)
    func walk_2View() -> some View {
        NavigationLink(
            "SHOULDN'T SEE (walk_2)",
            tag: WalkingState.walk_2, selection: $state) {
                DigitalTimerView(duration: countdown_TMP_Duration) {
                    // → .ending_interstitial
                    state = .ending_interstitial
                }.padding()
                    .navigationBarBackButtonHidden(true)
            }
        //                .hidden()
    }

    /// A `NavigationLink` for the closing screen (`ending_interstitial`)
    @ViewBuilder
    func ending_interstitialView() -> some View {
        // REGULAR farewell to the user.
        NavigationLink(
            "SHOULDN'T SEE (ending_interstitial)",
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
