//
//  DASIInterstitialViews.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/5/22.
//

import SwiftUI

// TODO: Store this text somewhere like a plist
let introPhaseText = """
The following questions ask about your ability to perform routine and recreational tasks. This is the only time you will be asked to complete this survey; use the "Next" and "Back" buttons to review your answers, as you will not be able to change them once the survay is complete.

Tap "Continue" to start the survey.
"""

let completionPhaseText = """
You have completed the survey.

This is the only time you will be asked to respond to this survey; you will not be able to change your answers once the survay is complete.

Tap "Back" to review your answers and change them if you wish.

Tap "Confirm" to record your responses and end the survey.
"""

struct DASIInterstitialView: View {
    @EnvironmentObject var pages: DASIPages


    let titleText: String
    let bodyText: String
    let systemImageName: String
    let continueTitle: String

    let phase: DASIPhase

    var body: some View {
        GeometryReader { proxy in
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
                Button(continueTitle) {
                    if phase == .intro {
                        pages.increment()
                    }
                    else if phase == .completion {
                        // Accepting would bump you to
                        // the next grand phase of the workflow.
                    }
                }
            }
            .navigationTitle(titleText)
        }

        //        withToolbar(original: gm)
    }
}

struct DASIInterstitialView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASIInterstitialView(titleText: "Finished",
                                 bodyText: completionPhaseText,
                                 systemImageName: "checkmark.square",
                                 continueTitle: "Confirm",
                                 phase: .completion)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← Back") {}
                }
            }
            .padding()
        }

        NavigationView {
            DASIInterstitialView(titleText: "Survey",
                                 bodyText: introPhaseText,
                                 systemImageName: "checkmark.square",
                                 continueTitle: "Continue",
                                 phase: .intro)
            .padding()
        }
    }
}
