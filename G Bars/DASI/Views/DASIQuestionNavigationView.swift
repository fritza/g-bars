//
//  DASIQuestionNavigationView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/1/22.
//

import SwiftUI

struct DASIQuestionNavigationView: View {
    @EnvironmentObject var status: DASIStatus

//    @State var displayedID: Int
    @State var currentAnswerState: AnswerState

    var body: some View {
        DASIQuestionView(
            question: DASIQuestion.questions[status.currentResponseIndex ?? 0],
            state: $currentAnswerState, onSelection: { question, answer in
                status.recordInCurrent(answer: answer)
                status.advance()
//                if question.id <= DASIQuestion.questions.count {
//                    displayedID += 1
//                    currentAnswerState = .unknown
//                }
            })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next →") {
                    status.recordInCurrent(answer: currentAnswerState)
                    status.advance()
//                    displayedID += 1
//                    currentAnswerState = .unknown
                }
                    .disabled(status.currentResponseIndex ?? 0 >= DASIQuestion.questions.count)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("← Back") {
                    status.recordInCurrent(answer: currentAnswerState)
                    status.decrement()
//                    displayedID -= 1
//                    currentAnswerState = .unknown
                }
                    .disabled(status.currentResponseIndex ?? 0 <= 1)
            }
        }
//        .animation(.easeInOut, value: displayedID)
        .animation(.easeInOut, value: status.currentResponseIndex)
    }
}

struct DASIQuestionNavigationView_Previews: PreviewProvider {
    @State static var currentAnswer = AnswerState.unknown

    static var previews: some View {
        NavigationView {
            DASIQuestionNavigationView(
//                displayedID: 2,
                currentAnswerState: currentAnswer)
        }
        .environmentObject(DASIStatus(phase: .responding(index: 2)))
    }
}
