//
//  YesNoStack.swift
//  CardSeries
//
//  Created by Fritz Anderson on 3/4/22.
//

import SwiftUI

/*
 RATS RATS RATS

 I think it might be best to bind the button selection so the stack sets/unsets the answer in client code.
 */

struct YesNoStack: View {
    typealias AnswerVoid = ((AnswerState) -> Void)

    /// The currently-selected AnswerState; client code provides a binding to the value.
    @Binding var boundState: AnswerState
    let selectionCallback: (AnswerState) -> Void

    init(boundState: Binding<AnswerState>,
         onSelection selected: @escaping (AnswerState) -> Void) {
        self._boundState = boundState
        selectionCallback = selected
    }

    func set(value: AnswerState) {
        boundState = value
        selectionCallback(value)
    }

    func yesNoButton(value: AnswerState, label: String,
                     in width: CGFloat) -> some View {
        YesNoButton(
            state: value, title: label,
            currentSelection: boundState,
            width: width * 0.8,
            completion: { set(value: $0) }
        )
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                yesNoButton(value: .yes, label: "Yes",
                            in: proxy.size.width)
                yesNoButton(value: .no, label: "No",
                            in: proxy.size.width)
                Spacer()
            }
            .padding()
        }
        .animation(.easeInOut, value: boundState)
    }
}

final class YNUState: ObservableObject, CustomStringConvertible {
    @State var answer: AnswerState = .no
    var description: String {
        let valueString: String
        switch answer {
        case .unknown:
            valueString = "?! "
        case .yes:
            valueString = "Yes"
        case .no:
            valueString = "No "
        }
       return "YNUState: \(valueString)"
    }
}

struct YesNoStack_Previews: PreviewProvider {
    @State static var ynuState: AnswerState = .yes
    @State static var last: String = "NONE"

    static var previews: some View {
        VStack(alignment: .center) {
            Spacer()
            YesNoStack(boundState: $ynuState) { _ in }
                .frame(height: 100, alignment: .center)
            Spacer()
            Text("The setting is \(ynuState.description)")
        }
    }
}
