//
//  YesNoButton.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/31/21.
//

import SwiftUI


// MARK: - YesNoButton
struct YesNoButton: View {
    let id: AnswerState
    var value: AnswerState { id }
    /// The `String` to display, possibly in addition to a checkmark
    let title: String
    /// Callback to notify the client of a click.
    let completion: ((AnswerState) -> Void)?

    /// Global state (display a checkmark in the title if self,id is the same))
    let selectedState: AnswerState

    let enclosingWidth: CGFloat

    init(state: AnswerState, title: String, currentSelection: AnswerState,
         width: CGFloat,
         completion: ( (AnswerState) -> Void)? ) {
        self.id = state
        self.title = title
        self.completion = completion
        self.selectedState = currentSelection
        enclosingWidth = width
    }

    /// Label for the button, depending on whether the button is selected.
    @ViewBuilder func checkedLabelView(text: String )
    -> some View {
        if id == selectedState {
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

    // MARK: body
    var body: some View {
        HStack(alignment: .center) {
            Button(
                action: {
                    /// Upon tao, tell the client via callback
                    completion?(self.value)
                },
                label: {
                    /// Checked or unchecked label
                    checkedLabelView(text: title)
                        .frame(width: enclosingWidth)
                })
        }        .buttonStyle(.bordered)

    }
}

// MARK: - Previews
struct YesNoButton_Previews: PreviewProvider {
    static let currently: AnswerState = .yes
    static var previews: some View {
        YesNoButton(state: .yes, title: "Often",
                    currentSelection: currently,  width: 330) {
            btn in
        }
        .padding()
        .frame(width: 400, height: 80, alignment: .center)
        YesNoButton(state: .no, title: "Rarely",
                    currentSelection: currently,  width: 330) {
            btn in
        }
        .padding()
        .frame(width: 400, height: 80, alignment: .center)
        
    }
}
