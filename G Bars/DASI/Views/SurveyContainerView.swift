//
//  SurveyContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI

struct SurveyContainerView: View {
    @StateObject var contentEnvt: DASIPages = DASIPages() // RootState.shared.dasiContent
    // FIXME: Too many EnvironmentObjects

    #if G_BARS
    @StateObject var dasiResponses = DASIResponseList()
    #else
    static let dasiResponses = DASIResponseList()
    #endif

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
                    contentEnvt.selected?.goForward()
                }
                NavigationLink(
                    isActive: $contentEnvt.refersToQuestion,
                    destination: {
                        // FIXME: Dummied-in just to save the compiler error.
                        DASIQuestionView(question: DASIQuestion.questions[2], state: $currentAnswer, onSelection: { q, a in
                        })
                        .navigationBarBackButtonHidden(true)
                    },

                    label: { EmptyView() }
                )
                NavigationLink(
                    tag: DASIStages.landing,
                    selection: $contentEnvt.selected,
                    destination: {
                        DASIOnboardView()
                        .navigationBarBackButtonHidden(true)
                },
                               label: {EmptyView()}
                )
                NavigationLink(tag: DASIStages.completion,
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
            #if G_BARS
            .environmentObject(dasiResponses)
            #endif
        }
    }
}

struct SurveyContainerView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyContainerView(contentEnvt: DASIPages(.landing))
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
