//
//  DASIInterstitialViews.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/5/22.
//

import SwiftUI

private let introPhaseText = """
The following questions ask about your ability to perform routine and recreational tasks. This is the only time you will be asked to complete this survey; use the "Next" and "Back" buttons to review your answers, as you will not be able to change them once the survay is complete.

Tap "Continue" to start the survey.
"""

private let completionPhaseText = """
You have completed the survey.

This is the only time you will be asked to respond to this survey; you will not be able to change your answers once the survay is complete.

Tap "Back" to review your answers and change them if you wish.

Tap "Confirm" to record your responses and end the survey.
"""

struct DASIInterstitialView: View {
    @EnvironmentObject var status: DASIResponseStatus

    let titleText: String
    let bodyText: String
    let systemImageName: String
    let continueTitle: String

    let phase: DASIPhase

    @ViewBuilder
    func withToolbar<V: View>(original: V) -> some View {
        if phase == .intro {
            original
        }
        else {
            original
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("← Back") {

                            // FIXME: handle the back button.
                            // SEE ALSO: DASIQuestionNavigationView
                            //           which also has next/back buttons.
                            // The wrapper approach is better because it can choose among the interstitials and questions.
                        }
                    }
                }
        }
    }

    var body: some View {
        let gm = GeometryReader { proxy in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: systemImageName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.accentColor)
                        .frame(width: 0.5*proxy.size.width)
                    Spacer()
                }
                Spacer()
                Text(bodyText)
                    .font(.body)
                Spacer()
                Button(continueTitle) {}
            }
            .navigationTitle(titleText)
        }

        withToolbar(original: gm)
    }
}

struct DASIInterstitialView_Previews: PreviewProvider {
    static let responseList: [AnswerState] = [
        .yes, .yes, .no, .no, .yes, .no
        ]

    static var previews: some View {
        NavigationView {
            DASIInterstitialView(titleText: "Finished",
                                 bodyText: completionPhaseText,
                                 systemImageName: "checkmark.square",
                                 continueTitle: "Confirm",
                                 phase: .completion)
            .padding()
        }
        .environmentObject(DASIResponseStatus(from: responseList))

        NavigationView {
            DASIInterstitialView(titleText: "Survey",
                                 bodyText: introPhaseText,
                                 systemImageName: "checkmark.square",
                                 continueTitle: "Continue",
                                 phase: .intro)
            .padding()
        }
        .environmentObject(DASIResponseStatus(from: responseList))
    }
}
