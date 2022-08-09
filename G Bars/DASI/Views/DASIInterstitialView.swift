//
//  DASIInterstitialView.swift
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
    @State var shouldShowLastScreenAlert: Bool = false

    let titleText: String
    let bodyText: String
    let systemImageName: String
    let continueTitle: String

    let phase: DASIPhase

    var body: some View {
        let gr = GeometryReader { proxy in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: systemImageName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.accentColor)
                        .frame(width: 0.5*proxy.size.width)
                        .symbolRenderingMode(.hierarchical)
                    Spacer()
                }
                .accessibilityLabel("icon")
                Spacer()
                Text(bodyText)
                    .font(.body)
                    .accessibilityLabel("descriptive text")
                Spacer()
                Button(continueTitle) {
                    if phase == .intro {
                        _ = pages.increment()
                    }
                    else if phase == .completion {
                        shouldShowLastScreenAlert = true
                        // Accepting would bump you to
                        // the next grand phase of the workflow.
                    }
                }
                .accessibilityLabel("continuation button")
            }
            .alert("No destination beyond DASI", isPresented: $shouldShowLastScreenAlert, actions: { },
                   message: {
                Text("The G Bars app doesn't integrate the phases of Step Test. You’ve gone as far as you can with the DASI survey.")
            })
            .padding()
            .navigationBarBackButtonHidden(true)
            .navigationTitle(titleText)
        }
        if phase == .completion {
            return AnyView(
                gr.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("← Back") {
                            _ = pages.decrement()
                        }
                    }   // button
                }   // toolbar
            )   // AnyView()
        }
        else {
            return AnyView(gr)
        }
    }
}

struct DASIInterstitialView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ZStack {
                DASIInterstitialView(titleText: "DASI Survey — Finished",
                                     bodyText: completionPhaseText,
                                     systemImageName: "checkmark.square",
                                     continueTitle: "Confirm",
                                     phase: .completion)
                .padding()
            }
        }

        NavigationView {
            ZStack {
                DASIInterstitialView(titleText: "DASI Survey",
                                     bodyText: introPhaseText,
                                     systemImageName: "checkmark.square",
                                     continueTitle: "Continue",
                                     phase: .intro)
                .padding()
            }
        }
    }
}
