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
@available(*, obsoleted: 0.0.0, "Use SurveyContainerView.")
struct DASIQuestionNavigationView: View {
    @EnvironmentObject var status: DASIResponseStatus
    //    @State var currentAnswerState: AnswerState

    var body: some View {
        DASIQuestionView()
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next →") {
                    status.advance()
                }
                .disabled(!status.canAdvance)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("← Back") {
                    status.retreat()
                }
                .disabled(!status.canRetreat)
            }
        }
//        .animation(.easeInOut, value: status.currentResponseIndex)
    }
}

struct DASIQuestionNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASIQuestionNavigationView()
                .environmentObject(DASIResponseStatus(from: [ .yes, .yes, .no, .no, .yes, .no ]))
        }
    }
}
