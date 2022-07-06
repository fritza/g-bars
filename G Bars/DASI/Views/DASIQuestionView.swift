//
//  DASIQuestionView.swift
//  CardSeries
//
//  Created by Fritz Anderson on 3/4/22.
//

import SwiftUI

/// A View that presents a ``DASIQuestion`` (text, id) and the response.
///
/// Displays the content in a `Text`, and a ``YesNoStack`` for the response.
///  _That is all._ The parent `View` gets a callback when the selection is made.
///  There is also a bound ``AnswerState`` to set and report the current selectioin.
struct DASIQuestionView: View {
    // @EnvironmentObject var status: DASIStatus

    @Binding var answerState: AnswerState
    let question: DASIQuestion
    let onSelection: ((DASIQuestion, AnswerState) -> Void)?

    init(question: DASIQuestion, state: Binding<AnswerState>,
         onSelection: ((DASIQuestion, AnswerState) -> Void)? = nil) {
        self.question = question
        self._answerState = state
        self.onSelection = onSelection
    }

    // FIXME: Verify that the report contents don't go away
    // before it's time to report.
    var body: some View {
        return VStack(alignment: .leading) {
            Text(question.text)
                .font(.title)
                .minimumScaleFactor(0.5)
            .padding()
            Spacer()
            YesNoStack(
                boundState: self.$answerState) {
                    onSelection?(question, $0)
                }
            .frame(height: 130)
            .padding()
        }

        .navigationTitle(
            "Survey — \(question.id)"
        )
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    @State static var aState: AnswerState = .unknown
    static var previews: some View {
        NavigationView {
            DASIQuestionView(question: DASIQuestion.questions[2],
                             state: $aState)
            //, onSelection: { q, a in
//            })
        }
    }
}
