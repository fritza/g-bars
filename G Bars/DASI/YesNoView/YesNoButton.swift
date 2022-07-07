//
//  YesNoButton.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/31/21.
//

import SwiftUI


// MARK: - YesNoButton
struct YesNoButton: View, Identifiable {
    let isSelected: Bool

    /// Convenience value for identifying the button when it's tapped.
    let id: Int
    /// The `String` to display, possibly in addition to a checkmark
    let title: String
    /// Callback to notify the client of a click.
    let completion: (YesNoButton) -> Void

    let fittingSize: CGSize

    //    let enclosingWidth: CGFloat

    init(_ title: String, identifier: Int, selected: Bool,
         fittingSize: CGSize,
         completion: @escaping (YesNoButton) -> Void) {
        self.title = title
        self.id = identifier
        self.isSelected = selected
        self.fittingSize = fittingSize
        self.completion = completion
        //        enclosingWidth = width
    }
    /// Label for the button, depending on whether the button is selected.
    @ViewBuilder func checkedLabelView(text: String)
    -> some View {
        if isSelected {
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
                    completion(self)
                },
                label: {
                    /// Checked or unchecked label
                    checkedLabelView(text: title)
                        .frame(width: fittingSize.width
                               , height: fittingSize.height)
                })
        }        .buttonStyle(.bordered)
    }
}

// MARK: - Previews
struct YesNoButton_Previews: PreviewProvider {
    @State static var currently: Int = 2
    static let bSize = CGSize(width: 320, height: 40)
    static var previews: some View {
        YesNoButton("Often", identifier: 1,
                    selected: currently == 1,
                    fittingSize: bSize)
                    { currently = $0.id }

        YesNoButton("Rarely", identifier: 2,
                    selected: currently == 2,
                    fittingSize: bSize)
        { currently = $0.id }
    }
}
