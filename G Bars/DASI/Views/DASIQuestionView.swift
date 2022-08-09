//
//  DASIQuestionView.swift
//  CardSeries
//
//  Created by Fritz Anderson on 3/4/22.
//

import SwiftUI

/// A View that presents a ``DASIQuestion`` (text, id). It does not have any interactive (e.g. button) content.
struct DASIQuestionView: View {
    @EnvironmentObject var responseStatus: DASIResponseStatus
    @EnvironmentObject var pages: DASIPages

    var body: some View {
        VStack(alignment: .leading) {
            Text(responseStatus.currentQuestion.text)
                .font(.title)
                .minimumScaleFactor(0.5)
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(
            "Survey — \(String(describing: responseStatus.currentQuestion.id))"
        )
    }
}

struct DASIQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASIQuestionView()
        }
        .environmentObject(DASIResponseStatus(
            from: [ .yes, .yes, .no, .no, .yes, .no ]
        ))
        .environmentObject(DASIPages(.responding(index: 3)))
    }
}
