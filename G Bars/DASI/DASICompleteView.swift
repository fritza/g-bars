//
//  DASICompleteView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

fileprivate let completionText = """
You have completed the survey portion of this exercise.
"""

fileprivate let startIncompleteText = """

NOTE: You still have
"""
fileprivate let endIncompleteText = """
 questions yet to answer.
"""

fileprivate var nextSteps: String {
#if G_BARS
    "You are free to select another phase from the tab bar at bottom."
#else
    if RootState.shared.allTasksFinished {
        return "\nPlease proceed to the “Report” view to submit your information to the team."
    }
    else {
        return "\nNow select the “Walk” tab below to proceed to the walking portion of the exercise."
    }
#endif
}

//let nextSteps = "NON-GLOBAL nextSteps"

// FIXME: Should there be a Back button?

struct DASICompleteView: View {
    @EnvironmentObject var envt: DASIPages
#if G_BARS
    @EnvironmentObject var reportContents: DASIResponseList
    @EnvironmentObject var contentEnvt: DASIPages
#else
    // FIxME: Take contents from global, not .environmentObject.
    var reportContents: DASIResponseList {
        RootState.shared.dasiResponses
    }
    @EnvironmentObject private var rootState: RootState
    #endif



    var allItemsAnswered: Bool {
        return reportContents.unknownResponseIDs.isEmpty
    }

    var instructions: String {
        var retval = completionText + nextSteps
        #if !G_BARS
        if !allItemsAnswered {
            let empties = reportContents.unknownResponseIDs
            retval += startIncompleteText + "\(empties.count)" + endIncompleteText
        }
        #endif
        return retval
    }

    var body: some View {
        VStack {
            ForwardBackBar(forward: false, back: true, action: { _ in
                #if G_BARS
                #else
                rootState.dasiContent.decrement()
                #endif
            })
                .frame(height: 44)
            Spacer()
//            GenericInstructionView(
//                titleText: "Survey Complete",
//                bodyText: instructions, // + completionText,
//                sfBadgeName: "checkmark.square")
//            .padding()
        }
        .navigationBarHidden(true)
        .onAppear{
            // IF ALL ARE ANSWERED
            if allItemsAnswered {
                #if G_BARS
                #else
                AppStage.shared
                    .completionSet
                    .insert(.dasi)
                // TODO: Maybe create the report data on completionSet changing.
                #endif
            }
        }
    }
}

struct DASICompleteView_Previews: PreviewProvider {
    static var previews: some View {
        DASICompleteView()
            .environmentObject(DASIPages())
    }
}
