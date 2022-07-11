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
    /// The currently-selected AnswerState; client code provides a binding to the value.
    @Binding var boundState: Int

    let callback: (Int) -> Void

    init(boundState: Binding<Int>, callback: @escaping (Int) -> Void) {
        self._boundState = boundState
        self.callback = callback
    }

    static let bSize = CGSize(width: 320, height: 40)

    func reset() {
        boundState = 0
        callback(0)
    }

    func set(value: Int) {
        boundState = value
        callback(value)
    }

    func yesNoButton(_ buttonTitle: String, identifier: Int,
                     selected: Bool, inSize size: CGSize
                     ) -> some View {
        YesNoButton(buttonTitle, identifier: identifier,
                    selected: selected,
                    fittingSize: Self.bSize) { button in
            set(value: button.id)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center) {
                Spacer()
                yesNoButton("Yes", identifier: 1, selected: boundState == 1, inSize: proxy.size)
                yesNoButton("No" , identifier: 2, selected: boundState == 2, inSize: proxy.size)
            }

            .padding()
        }
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
    @State static var ynuState: Int = 1
    @State static var last: String = "NONE"

    static var previews: some View {
        VStack(alignment: .center) {
            Spacer()
            YesNoStack(boundState: $ynuState) {
                print($0)
            }
            Spacer()
            Text("The setting is \(ynuState)")
        }
    }
}
