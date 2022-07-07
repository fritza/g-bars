//
//  DASIQuestionItemView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/1/22.
//

import SwiftUI

struct DASIQuestionItemView: View {
    let content: String

    internal init(content: String) {
        self.content = content
    }

    var body: some View {
        Text(content)
            .font(.title)
            .minimumScaleFactor(0.5)
    }
}

struct DASIQuestionItemView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(2..<8) { index in
                DASIQuestionItemView(content:
                                        "For Rent, see Owner."
                                        //DASIQuestion.questions[index]
                )
            }
        }
    }
}
