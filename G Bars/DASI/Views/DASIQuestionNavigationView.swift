//
//  DASIQuestionNavigationView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/1/22.
//

import SwiftUI

struct DASIQuestionNavigationView: View {
    @State var displayedID: Int
    @State var currentAnswerState: AnswerState

    var body: some View {
        DASIQuestionView(
            question: DASIQuestion.questions[displayedID-1],
            state: $currentAnswerState, onSelection: { question, answer in
                if question.id <= DASIQuestion.questions.count {
                    displayedID += 1
                    currentAnswerState = .unknown
                }
            })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next →") {
                    displayedID += 1
                    currentAnswerState = .unknown
                }
                    .disabled(displayedID >= DASIQuestion.questions.count)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("← Back") {
                    displayedID -= 1
                    currentAnswerState = .unknown
                }
                    .disabled(displayedID <= 1)
            }
        }
        .animation(.easeInOut, value: displayedID)
    }
}

struct DASIQuestionNavigationView_Previews: PreviewProvider {
    @State static var currentAnswer = AnswerState.unknown

    static var previews: some View {
        NavigationView {
            DASIQuestionNavigationView(
                displayedID: 2,
                currentAnswerState: currentAnswer)
        }
    }
}
