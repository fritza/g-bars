//
//  DASIYNQuestionView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/8/22.
//

import SwiftUI

struct DASIYNQuestionView: View {
    @State var yesNoState: Int = 0
    @EnvironmentObject var pages: DASIPages
    @EnvironmentObject var responseStatus: DASIResponseStatus

    var body: some View {
        VStack {
            DASIQuestionView()
            Spacer()
            YesNoStack(boundState: $yesNoState) {
                newYNIndex in
                let newYNState: AnswerState
                switch newYNIndex {
                case 0: newYNState = .unknown
                case 1: newYNState = .yes
                case 2: newYNState = .no
                default: fatalError("Got a nonsense value \(newYNIndex) in \(#function)")
                }
                responseStatus.currentValue = newYNState
//                responseStatus.advance()
                _ = pages.increment()

                yesNoState = responseStatus.currentValue.ynButtonNumber
                print()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("← Back") {
                    _ = pages.decrement()
                    if pages.selected >= DASIPhase.minResponsePhase {
                        yesNoState = responseStatus.currentValue.ynButtonNumber
                        // Need to load up the view with
                        // any previously-set response.
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next →") {
                    _ = pages.increment()
                    if pages.selected <= DASIPhase.maxResponsePhase {
                        yesNoState = responseStatus.currentValue.ynButtonNumber
                        // Need to load up the view with
                        // any previously-set response.
                    }
                }
            }
        }
        .onChange(of: yesNoState) { _ in
        }
    }
}

struct DASIYNQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASIYNQuestionView()
                .environmentObject(DASIPages())
                .environmentObject(DASIResponseStatus())
        }
    }
}
