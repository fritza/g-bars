//
//  YesNoButton.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/31/21.
//

import SwiftUI


// MARK: - YesNoButton
struct YesNoButton: View {

    let id: Int
    /// The `String` to display, possibly in addition to a checkmark
    let title: String
    /// Callback to notify the client of a click.
    let completion: ((YesNoButton) -> Void)?

    /// Button state (wheter to display a checkmark in the title)
    let isChecked: Bool

    let enclosingWidth: CGFloat

    init(id: Int, title: String, checked: Bool,
         width: CGFloat,
         completion: ( (YesNoButton) -> Void)? ) {
        self.id = id
        self.title = title
        self.isChecked = checked
        self.completion = completion
        enclosingWidth = width
    }

    /// Label for the button, depending on whether the button is selected.
    @ViewBuilder func checkedLabelView(text: String )
    -> some View {
        if isChecked {
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
                    completion?(self)
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
    static var previews: some View {
        YesNoButton(id: 1, title: "Rarely", checked: true, width: 330) {
            btn in
        }
        .padding()
        .frame(width: 400, height: 80, alignment: .center)

        YesNoButton(id: 1, title: "Often", checked: false, width: 330) {
            btn in
        }
        .padding()
        .frame(width: 400, height: 80, alignment: .center)
    }
}
