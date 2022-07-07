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

    var body: some View {
        NavigationView {
            VStack {
                Text(
                    "SHOULD NOT APPEAR(\(contentEnvt.selected?.description ?? "EMPTY"))"
                )
                Button("RATS Next") {
                    assert(contentEnvt.selected != nil)
//                    contentEnvt.selected =
                    contentEnvt.selected!.advance()
                }
                NavigationLink(
                    isActive: $contentEnvt.refersToQuestion,
                    destination: {
                        // FIXME: Dummied-in just to save the compiler error.
                        DASIQuestionView()
                        .navigationBarBackButtonHidden(true)
                    },

                    label: { EmptyView() }
                )
                NavigationLink(
                    tag: DASIPhase.intro,
                    selection: $contentEnvt.selected,
                    destination: {
                        DASIInterstitialView(
                            titleText: "Finished", bodyText: introPhaseText,
                            systemImageName: "checkmark.square",
                            continueTitle: "Continue",
                            phase: .intro)
//                        DASIOnboardView()
//                        .navigationBarBackButtonHidden(true)
                },
                               label: {EmptyView()}
                )
                NavigationLink(tag: DASIPhase.completion,
                               selection: $contentEnvt.selected,
                               destination: {
                    DASICompleteView()
                        .navigationBarBackButtonHidden(true)
                },
                               label: {EmptyView()}
                )
            }
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
            }
        }
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
