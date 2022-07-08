//
//  SurveyContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI


// TODO: Put `DASIResponseStatus` into the environment
//       originating at the App level.
// TODO: Put DASIPages into the environment
/// Host to `NavigationLink`s that display interstitials and DASI questions.
struct SurveyContainerView: View {
    @EnvironmentObject var dasiResponses: DASIResponseStatus
    @EnvironmentObject var contentEnvt: DASIPages

    @State var currentAnswer: AnswerState = .unknown
    @State var yesNoState: Int = 1

    var body: some View {
//        NavigationView {
        VStack {


             //                Text(
             //                    "SHOULD NOT APPEAR(\(contentEnvt.selected.description))"
             //                )
             //                Button("RATS Next") {
             //                    _ = contentEnvt.increment()
             //                }

             // MARK: Questions

            NavigationLink(tag: true, selection: $contentEnvt.refersToQuestion, destination: {
                VStack {
                    DASIYNQuestionView()
                }
            }, label: {
                EmptyView()
            }
            )
//            .environmentObject(yesNoState)

            /*
            NavigationLink(
                isActive: $contentEnvt.refersToQuestion,
             destination: {
             VStack {
             DASIQuestionView()
}   }
             YesNoStack(boundState: $yesNoState)
             Text("Integer state = \(yesNoState)")

             // NOTE WELL:
             // .onChange is executed _after_ the following
             // Text accesses .currentValue.
             Text("Transmitted state = \(rootResponseStatus.currentValue.description)")
             }
             .onChange(of: yesNoState) { newValue in
             rootResponseStatus.currentValue =
             (newValue == 1) ? .yes : .no
             }
             .toolbar {
             ToolbarItem(placement: .navigationBarLeading) {
             Button("← Back") {
             _ = contentEnvt.decrement()
             }
             }
             ToolbarItem(placement: .navigationBarLeading) {
             Button("Next →") {
             _ = contentEnvt.increment()
             }
             }
             }
             },
             label: { EmptyView() }
             )
             */

            // MARK: .completion
            NavigationLink(
                tag: DASIPhase.completion,
                selection: $contentEnvt.selected,
                destination: {
                    DASIInterstitialView(
                        titleText: "Survey Completed",
                        bodyText: completionPhaseText,
                        systemImageName: "checkmark.square",
                        continueTitle: "Continue (not in partial demo)",
                        phase: DASIPhase.completion)
                },
                label: {EmptyView()}
            )

            // MARK: Onboarding
            NavigationLink(
                tag: DASIPhase.intro,
                selection: $contentEnvt.selected,
                destination: {
                    DASIInterstitialView(
                        titleText: "DASI Survey",
                        bodyText: introPhaseText,
                        systemImageName: "checkmark.square",
                        continueTitle: "Continue",
                        phase: DASIPhase.intro)
                },
                label: {EmptyView()}
            )
        }
        .navigationBarBackButtonHidden(true)
        // FIXME: This doesn't update global completion.
        .onDisappear {
            // Does this belong at disappearance
            // of the tab? We want a full count of
            // responses + concluding screen.
            // ABOVE ALL, don't post the initial screen
            // as soon as the conclusion screen is
            // called for.

#if !G_BARS
            if Self.dasiResponses // RootState.shared.dasiResponses
                .unknownResponseIDs.isEmpty {
                RootState.shared.didComplete(phase: .dasi)
            }
            else {
                RootState.shared.didNotComplete(phase: .dasi)
            }
#endif
            //   }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SurveyContainerView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyContainerView()
            .environmentObject(DASIResponseStatus())
            .environmentObject(DASIPages())
    }
}

/*
 WORKS: Observing the environment to select self's content.
 Next, how to select the next contained view.
 var body: some View {
 NavigationView {
 VStack {
 Text(contentEnvt.selected.rawValue)
 Button("Next") {
 contentEnvt.selected = contentEnvt.selected.next
 }
 }
 .navigationTitle("Containment")
 }
 }

 */
