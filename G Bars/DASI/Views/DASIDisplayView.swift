//
//  DASIDisplayView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/11/22.
//

import SwiftUI

/**
 Demo-only `View` that displays responses to each DASI question.
 */
struct DASIDisplayView: View {
    @EnvironmentObject var pages: DASIPages
    @EnvironmentObject var responses: DASIResponseStatus

    /// All responses as represented by a single line of CSV
    var csvLine: String {
        return responses.csvLine
    }

    var body: some View {
        VStack {
            // Text for whether all questions are complete
            Text("The user would \(responses.unknownIdentifiers.isEmpty ? "" : "not") be permitted to submit.\n" )
            + Text(self.csvLine)
                .font(.custom("Courier", size: 9,
                              relativeTo: .caption))
            // Responses to each question
            List(DASIQuestion.questions){ question in
                HStack {
                    Text(responses.allAnswers[question.id - 1].glyph)
                    Divider()
                    Text(question.text)
                }
                .font(.caption)
            }
            .listStyle(.plain)
        }   // VStack
        .navigationTitle("Summary (test only)")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("← Back") {
                    _ = pages.decrement()
                }
            }   // Back button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next →") {
                    _ = pages.increment()
                }
            }   // Next button
        }   // toolbar
    }   // body
}   // struct

struct DASIDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASIDisplayView()
                .padding()
        }
        .environmentObject(DASIPages())
        .environmentObject(DASIResponseStatus(from: [
            .yes, .yes, .no , .no,
            .no , .no , .yes, .no,
            .no , .yes, .yes, .no,
        ]))
    }
}
