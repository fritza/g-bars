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
    @EnvironmentObject var status: DASIStatus

    let titleText: String
    let bodyText: String
    let systemImageName: String
    let continueTitle: String

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
        if status.currentPhase != .intro {
            return AnyView(
                gm
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("← Back") {
                                status.decrement()
                            }
                            //                        .disabled(status.currentPhase == .intro)
                        }
                    }
            )}
        else { return AnyView(gm) }
    }
}

struct DASIInterstitialView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            DASIInterstitialView(titleText: "Finished",
                                 bodyText: completionPhaseText,
                                 systemImageName: "checkmark.square",
                                 continueTitle: "Confirm")
            .padding()
        }
        .environmentObject(DASIStatus(phase: .completion))

        NavigationView {
            DASIInterstitialView(titleText: "Survey",
                                 bodyText: introPhaseText,
                                 systemImageName: "checkmark.square",
                                 continueTitle: "Continue")
            .padding()
        }
        .environmentObject(DASIStatus(phase: .intro))
    }
}
