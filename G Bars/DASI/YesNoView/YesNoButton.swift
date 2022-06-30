//
//  YesNoButton.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/31/21.
//

import SwiftUI


// MARK: - YesNoButton
struct YesNoButton: View {
    // FIXME: "choiceView" is a bad name for a ViewChoice
    //    let choiceView: ViewChoice
    //    let contextSize: CGSize

    // FICME: global response list from global sted environment?
#if G_BARS
    @EnvironmentObject var reportContents: DASIResponseList
#else
    var reportContents: DASIResponseList = RootState.shared.dasiResponses
#endif

    // FIXME: Direct access to the content state
    @EnvironmentObject var envt: DASIPages

    let enclosingWidth: CGFloat

    let id: Int
    let title: String
    let completion: ((YesNoButton) -> Void)?
    @State var isChecked = false

    static let buttonHeight: CGFloat = 48
    static let buttonWidthFactor: CGFloat = 0.9

    var shouldBeChecked: Bool {
        // FIXME: Direct access to the content state
        guard let currentID = envt.questionIdentifier,
              let answer = reportContents.responseForQuestion(identifier: currentID)
        else {
            return false
        }
        switch answer {
        case .no: return self.id == 2
        case .unknown: return false
        case .yes: return self.id == 1
        }
    }

    @ViewBuilder func checkedLabelView(text: String, checked: Bool = false) -> some View {
        if checked {
            HStack(alignment: .center) {
                Image(systemName: "checkmark.circle")
                Text(text)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
        else {
            Text(text)
                .font(.title2)
                .fontWeight(.semibold)
        }
    }

    init(id: Int, title: String, width: CGFloat,
         completion: ( (YesNoButton) -> Void)? ) {
        self.id = id
        self.title = title
        self.completion = completion
        enclosingWidth = width
    }

    // MARK: body
    var body: some View {
        HStack(alignment: .center) {
            Button(
                action: {
                    completion?(self)
                },
                label: {
                    checkedLabelView(text: title, checked: isChecked)
                        .frame(width: enclosingWidth)
                })
        }        .buttonStyle(.bordered)

    }
}

// MARK: - Previews
struct YesNoButton_Previews: PreviewProvider {
    static var previews: some View {
        //        HStack {
        //            Color(.red)
        YesNoButton(id: 1, title: "Rarely", width: 330) {
            btn in
            btn.isChecked.toggle()
        }
        .padding()
        .frame(width: 400, height: 80, alignment: .center)
#if G_BARS
        .environmentObject(DASIResponseList())
        .environmentObject(DASIPages())
#endif
    }
}
