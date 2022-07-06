//
//  DASIQuestionNavigationView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/1/22.
//

/*
 What's my hierarchy here?
 Questions, bottom to top:

 YesNoButton
 YesNoStack
 --- Up through here, the views are agnostic about what question is asked.
 --- YesNoStack binds to a Bool _and_ issues a callback with every button click.
 Are both necessary? See next layers:

 ((QuestionContentView ... Delete, it's trivial and belongs in DASIQuestionView.))

 DASIQuestionView Displays the question's title and text, and provides a YesNoStack for the results. It seems not to care about the DASIStatus.
 It shares a binding to the answer up to the superview and down into the YesNoStack.
 It _also_ accepts a callback closure announcing the new y/n/u value and the DASIQuestion to which it responded.
 A big question is: Does the superview need both? The reason this is important is that the stored response has to be in sync with the y/n selection.

 Consider the array of responses in DASIStatus `responses` array.
 The trigger is in the DASIQuestionView callback and in its bound answer.
 Can't we add an .onChanged modifier to whichever the container view is?
 As it happens, DASIQuestionView has a binding specifically to an AnswerState already.

 So who's presenting that nowadays?  DASIQuestionNavigationView (here)? or SurveyContainerView? Both present DASIQuestionView.

 */

import SwiftUI

struct DASIQuestionNavigationView: View {
    @EnvironmentObject var status: DASIStatus
    //    @State var currentAnswerState: AnswerState

    var body: some View {
        DASIQuestionView(
            question: DASIQuestion.questions[status.currentResponseIndex ?? 0],
            state: $status.responses[status.currentResponseIndex!]
        )
        // It _looks_ like merely setting the response
        // can trigger advance().
        .onChange(of: status.responses[status.currentResponseIndex!], perform: { _ in  status.advance() })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next →") {
                    // If the binding works as I hope,
                    // there's no need to sync-up the stored value.
                    status.advance()
                }
                .disabled(status.currentResponseIndex ?? 0 >= DASIQuestion.questions.count)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("← Back") {
                    // If the binding works as I hope,
                    // there's no need to sync-up the stored value.
                    status.decrement()
                }
                .disabled(status.currentResponseIndex ?? 0 <= 1)
            }
        }
        .animation(.easeInOut, value: status.currentResponseIndex)
    }
}

struct DASIQuestionNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASIQuestionNavigationView()
                .environmentObject(DASIStatus(phase: .responding(index: 2)))
        }
    }
}
