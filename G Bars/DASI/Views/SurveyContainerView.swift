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
        List {
             // MARK: Questions

            NavigationLink(tag: SurveyProgress.questionProgress,
                           selection: $contentEnvt.surveyProgress,
                           destination: {
                VStack {
                    DASIYNQuestionView()
                }
            }, label: {
                Text("Question - \(contentEnvt.selected.description) - Match? \(String(describing: SurveyProgress.questionProgress == contentEnvt.surveyProgress))")
            }
            )
//            .environmentObject(yesNoState)

            // MARK: .completion
            NavigationLink(
                tag: SurveyProgress.completionProgress,
                selection: $contentEnvt.surveyProgress,
                destination: {
                    DASIInterstitialView(
                        titleText: "Survey Completed",
                        bodyText: completionPhaseText,
                        systemImageName: "checkmark.square",
                        continueTitle: "Continue (not in partial demo)",
                        phase: DASIPhase.completion)
                },
                label: {
                    Text("Completion -  \(contentEnvt.selected.description) - Match? \(String(describing: SurveyProgress.completionProgress == contentEnvt.surveyProgress))")
                }
            )

            // MARK: Onboarding
            NavigationLink(
                tag: SurveyProgress.introProgress,
                selection: {
                    print("Progress =", contentEnvt.surveyProgress ?? "none")
                    return $contentEnvt.surveyProgress
                }()
//                    $contentEnvt.surveyProgress
            )
            {
//                Text("Well?")
                DASIInterstitialView(titleText: "Survey",
                                     bodyText: introPhaseText,
                                     systemImageName: "checkmark.square",
                                     continueTitle: "Continue",
                                     phase: .intro)
            }
        label: {
            Text("Onboarding -  \(contentEnvt.selected.description) - Match? \(String(describing: SurveyProgress.introProgress == contentEnvt.surveyProgress))")
        }

            NavigationLink(tag: SurveyProgress.displayProgress,
                           selection: $contentEnvt.surveyProgress) {
                Text("Display View\nfor rent")
            } label: {
                Text("Display - \(contentEnvt.selected.description) - Match? \(String(describing: SurveyProgress.displayProgress == contentEnvt.surveyProgress))")
            }
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
            .environmentObject(DASIPages(.intro))
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
