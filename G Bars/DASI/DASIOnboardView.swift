//
//  DASIOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI

#if G_BARS
struct DASIOnboardView: View {
    private let imageScale: CGFloat = 0.6

    static let instructions = """
    In this part of the assessment, you will be asked \(DASIQuestion.count) questions about how well you do with various activities.

    Answer “Yes” or “No” to each. You will be able to move backward and forward through the questions, but you must respond to all for this exercise to be complete.
    """

    func iconView(in size: CGSize) ->  some View {
        Image(systemName: "checkmark.square")
            .resizable()
            .scaledToFit()
            .foregroundColor(.accentColor)
            .frame(
                height: size.width * imageScale, alignment: .center)
    }

    @EnvironmentObject var envt: DASIPages
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()

                iconView(in: proxy.size)
                Spacer()
                Text(Self.instructions)
                    .font(.body)
                    .padding()
                    .minimumScaleFactor(/*@START_MENU_TOKEN@*/0.5/*@END_MENU_TOKEN@*/)
            }
        }
        .navigationTitle("DASI Survey")
    }
}
#else
struct DASIOnboardView: View {
static let instructions = """
In this part of the assessment, you will be asked \(DASIQuestion.count) questions about how well you do with various activities.

Answer “Yes” or “No” to each. You will be able to move backward and forward through the questions, but you must respond to all for this exercise to be complete.
"""

    @EnvironmentObject var envt: DASIPages


    // TODO: Add the forward/back bar.

    var body: some View {
        VStack {
            GenericInstructionView(
                titleText: "Activity Survey",
                bodyText: Self.instructions,
                sfBadgeName: "checkmark.square",
                proceedTitle: "Continue") {
                    envt.increment()
                }
                .padding()
                .navigationBarHidden(true)
        }
        .onAppear{
        }
    }
}
#endif

struct DASIOnboardView_Previews: PreviewProvider {
    static var previews: some View {
        DASIOnboardView()
            .environmentObject(DASIPages(.landing))
    }
}
